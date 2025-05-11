import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowledge_assistant/bloc/collection_detail_bloc.dart';
import 'package:knowledge_assistant/bloc/events/collection_detail_event.dart';
import 'package:knowledge_assistant/ui/widgets/combobox_widget.dart';
import 'package:knowledge_assistant/ui/widgets/textfield_decorated.dart';

enum SourceTypeOption { file, git, url }

class InlineSourcePanel extends StatefulWidget {
  final String collectionId;

  final Function? onDone;

  const InlineSourcePanel({super.key, required this.collectionId, this.onDone});

  @override
  _InlineSourcePanelState createState() => _InlineSourcePanelState();
}

class _InlineSourcePanelState extends State<InlineSourcePanel> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  SourceTypeOption _selectedType = SourceTypeOption.file;
  PlatformFile? _selectedFile;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 40),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add source',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            ComboBox<SourceTypeOption>(
              value: _selectedType,
              showSearch: false,
              width: 200,
              onChanged: (type) {
                setState(() {
                  _selectedType = type!;
                  _locationController.clear();
                  _selectedFile = null;
                });
              },
              items:
                  SourceTypeOption.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(
                        type.toString().split('.').last.toUpperCase(),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 12),
            TextFieldDecorated(
              controller: _nameController,
              labelText: "Source name",
              hintText: "Enter source name",
            ),
            const SizedBox(height: 12),
            if (_selectedType == SourceTypeOption.file) ...[
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.attach_file),
                label: const Text('Select file'),
              ),
              if (_selectedFile != null) ...[
                const SizedBox(height: 8),
                Text(_selectedFile!.name),
              ],
            ] else ...[
              TextFieldDecorated(
                controller: _locationController,
                labelText:
                    _selectedType == SourceTypeOption.git ? 'Git URL' : 'URL',
                hintText: "Enter URL...",
              ),
            ],
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Index'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    switch (_selectedType) {
      case SourceTypeOption.file:
        if (_selectedFile == null) return;
        context.read<CollectionDetailBloc>().add(
          AddFileSourceToCollection(
            collectionId: widget.collectionId,
            name: name,
            file: _selectedFile!,
          ),
        );
        break;
      case SourceTypeOption.git:
        final location = _locationController.text.trim();
        if (location.isEmpty) return;
        context.read<CollectionDetailBloc>().add(
          AddGitSourceToCollection(
            collectionId: widget.collectionId,
            name: name,
            gitUrl: location,
          ),
        );
        break;
      case SourceTypeOption.url:
        final location = _locationController.text.trim();
        if (location.isEmpty) return;
        context.read<CollectionDetailBloc>().add(
          AddUrlSourceToCollection(
            collectionId: widget.collectionId,
            name: name,
            url: location,
          ),
        );
        break;
    }

    // Clear form
    _nameController.clear();
    _locationController.clear();
    setState(() {
      _selectedFile = null;
    });

    if (widget.onDone != null) {
      widget.onDone!();
    }
  }
}
