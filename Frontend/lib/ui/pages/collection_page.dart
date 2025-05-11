import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge_assistant/bloc/collection_detail_bloc.dart';
import 'package:knowledge_assistant/bloc/events/collection_detail_event.dart';
import 'package:knowledge_assistant/bloc/states/collection_detail_state.dart';
import 'package:knowledge_assistant/ui/widgets/combobox_widget.dart';
import 'package:knowledge_assistant/ui/widgets/elevated_icon_button.dart';
import 'package:knowledge_assistant/ui/widgets/source_panel_widget.dart';
import 'package:knowledge_assistant/ui/widgets/textfield_decorated.dart';

class CollectionPage extends StatefulWidget {
  final String collectionId;

  const CollectionPage({super.key, required this.collectionId});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage>
    with SingleTickerProviderStateMixin {
  bool _showInlinePanel = false;

  @override
  void initState() {
    super.initState();
    context.read<CollectionDetailBloc>().add(
      LoadCollectionDetail(widget.collectionId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Collection')),
      body: BlocBuilder<CollectionDetailBloc, CollectionDetailState>(
        builder: (context, state) {
          if (state is CollectionDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CollectionDetailLoaded) {
            final collection = state.collection;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    collection.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  child: ElevatedIconButton(
                    width: 180,
                    icon: const Icon(Icons.question_mark),
                    child: const Text('Request'),
                    onPressed:
                        () => GoRouter.of(
                          context,
                        ).push('/chat/${widget.collectionId}'),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 50,
                      ),
                      child: Column(
                        children: [
                          ...collection.sources.map(
                            (source) => SourcePanel(
                              source: source,
                              collectionId: widget.collectionId,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: [
                        if (_showInlinePanel)
                          AnimatedSize(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeInOut,
                            child: _InlineSourcePanel(
                              collectionId: widget.collectionId,
                            ),
                          ),
                        SizedBox(height: 16),
                        ElevatedIconButton(
                          width: 150,
                          icon: const Icon(Icons.add),
                          onPressed:
                              () => setState(() {
                                _showInlinePanel = !_showInlinePanel;
                              }),
                          child: const Text("Add source"),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (state is CollectionDetailError) {
            return Center(child: Text(state.message));
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

class _InlineSourcePanel extends StatefulWidget {
  final String collectionId;

  const _InlineSourcePanel({required this.collectionId});

  @override
  State<_InlineSourcePanel> createState() => _InlineSourcePanelState();
}

class _InlineSourcePanelState extends State<_InlineSourcePanel> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  String _type = 'file';
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 70),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.indigo.shade400.withAlpha(80)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add source', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextFieldDecorated(
            controller: _nameController,
            labelText: "Name",
            hintText: "Source name",
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ComboBox<String>(
                value: _type,
                showSearch: false,
                width: 150,
                items: [
                  DropdownMenuItem(value: 'file', child: Text('File')),
                  DropdownMenuItem(value: 'git', child: Text('Git')),
                  DropdownMenuItem(value: 'url', child: Text('URL')),
                ],
                onChanged: (val) => setState(() => _type = val!),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFieldDecorated(
                  controller: _locationController,
                  labelText: "Path/URL",
                  hintText: "Source path or URL",
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _isSubmitting
              ? const Center(child: CircularProgressIndicator())
              : Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _onSubmit,
                  icon: const Icon(Icons.add),
                  label: const Text("Index"),
                ),
              ),
        ],
      ),
    );
  }

  void _onSubmit() {
    setState(() => _isSubmitting = true);

    context.read<CollectionDetailBloc>().add(
      AddSourceToCollection(
        collectionId: widget.collectionId,
        name: _nameController.text.trim(),
        type: _type,
        location: _locationController.text.trim(),
      ),
    );

    Future.delayed(const Duration(milliseconds: 200)).then((_) {
      if (!mounted) return;
      setState(() {
        _nameController.clear();
        _locationController.clear();
        _type = 'file';
        _isSubmitting = false;
      });
    });
  }
}
