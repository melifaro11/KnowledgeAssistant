import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowledge_assistant/bloc/collection_detail_bloc.dart';
import 'package:knowledge_assistant/bloc/events/collection_detail_event.dart';
import 'package:knowledge_assistant/ui/widgets/elevated_icon_button.dart';
import 'package:knowledge_assistant/ui/widgets/textfield_decorated.dart';

class InlineSourcePanel extends StatefulWidget {
  final String collectionId;

  final Function? onDone;

  const InlineSourcePanel({super.key, required this.collectionId, this.onDone});

  @override
  _InlineSourcePanelState createState() => _InlineSourcePanelState();
}

class _InlineSourcePanelState extends State<InlineSourcePanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _nameController = TextEditingController();

  PlatformFile? _pickedFile;

  final _gitUrlController = TextEditingController();
  final _branchController = TextEditingController(text: 'main');
  final _depthController = TextEditingController(text: '1');

  // URL tab
  final _urlController = TextEditingController();
  final _maxDepthController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _gitUrlController.dispose();
    _branchController.dispose();
    _depthController.dispose();
    _urlController.dispose();
    _maxDepthController.dispose();
    super.dispose();
  }

  void _onAddSource() {
    final bloc = context.read<CollectionDetailBloc>();
    final name = _nameController.text;
    final collectionId = widget.collectionId;

    switch (_tabController.index) {
      case 0:
        if (_pickedFile != null) {
          bloc.add(
            AddFileSourceToCollection(
              collectionId: collectionId,
              name: name,
              file: _pickedFile!,
            ),
          );
        }
        break;
      case 1:
        final config = {
          'branch': _branchController.text,
          'depth': int.tryParse(_depthController.text) ?? 1,
        };
        bloc.add(
          AddGitSourceToCollection(
            collectionId: collectionId,
            name: name,
            gitUrl: _gitUrlController.text,
            config: config,
          ),
        );
        break;
      case 2:
        final config = {
          'max_depth': int.tryParse(_maxDepthController.text) ?? 1,
        };
        bloc.add(
          AddUrlSourceToCollection(
            collectionId: collectionId,
            name: name,
            url: _urlController.text,
            config: config,
          ),
        );
        break;
    }

    if (widget.onDone != null) {
      widget.onDone!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: DefaultTabController(
        length: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'File'),
                Tab(text: 'Git'),
                Tab(text: 'URL'),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              child: TextFieldDecorated(
                controller: _nameController,
                labelText: "Source name",
                hintText: "Enter source name",
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 140,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // File Tab
                  Column(
                    children: [
                      ElevatedIconButton(
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles();
                          if (result != null) {
                            setState(() {
                              _pickedFile = result.files.first;
                            });
                          }
                        },
                        child: Text(
                          _pickedFile == null
                              ? 'Select file'
                              : _pickedFile!.name,
                        ),
                      ),
                    ],
                  ),

                  // Git Tab
                  Column(
                    spacing: 5,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 40,
                        ),
                        child: TextFieldDecorated(
                          controller: _gitUrlController,
                          labelText: "Git URL",
                          hintText: "Enter git URL",
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 40,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFieldDecorated(
                                controller: _branchController,
                                labelText: "Branch",
                                hintText: "Branch",
                              ),
                            ),
                            const SizedBox(width: 20),
                            TextFieldDecorated(
                              controller: _depthController,
                              width: 120,
                              keyboardType: TextInputType.number,
                              labelText: "Depth",
                              hintText: "Depth",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // URL Tab
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 40,
                        ),
                        child: TextFieldDecorated(
                          controller: _urlController,
                          labelText: "URL",
                          hintText: "Enter URL...",
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 40,
                        ),
                        child: TextFieldDecorated(
                          controller: _maxDepthController,
                          keyboardType: TextInputType.number,
                          labelText: "Max. depth",
                          hintText: "Max. depth",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: ElevatedIconButton(
                  onPressed: _onAddSource,
                  width: 200,
                  child: const Text('Indexing'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
