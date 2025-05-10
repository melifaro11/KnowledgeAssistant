import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge_assistant/bloc/collection_detail_bloc.dart';
import 'package:knowledge_assistant/bloc/events/collection_detail_event.dart';
import 'package:knowledge_assistant/bloc/states/collection_detail_state.dart';
import 'package:knowledge_assistant/ui/widgets/elevated_icon_button.dart';
import 'package:knowledge_assistant/ui/widgets/source_panel_widget.dart';

class CollectionPage extends StatefulWidget {
  final String collectionId;

  const CollectionPage({super.key, required this.collectionId});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  @override
  void initState() {
    super.initState();
    context.read<CollectionDetailBloc>().add(
      LoadCollectionDetail(widget.collectionId),
    );
  }

  void _addSourceDialog() {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    String type = 'file';

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Add source'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                DropdownButton<String>(
                  value: type,
                  items: const [
                    DropdownMenuItem(value: 'file', child: Text('File')),
                    DropdownMenuItem(value: 'git', child: Text('Git')),
                    DropdownMenuItem(value: 'url', child: Text('URL')),
                  ],
                  onChanged: (val) => setState(() => type = val!),
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Path / URL'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  context.read<CollectionDetailBloc>().add(
                    AddSourceToCollection(
                      collectionId: widget.collectionId,
                      name: nameController.text,
                      type: type,
                      location: locationController.text,
                    ),
                  );
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Collection')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSourceDialog,
        child: const Icon(Icons.add),
      ),
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
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    collection.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: ElevatedIconButton(
                    width: 250,
                    icon: const Icon(Icons.search),
                    child: const Text('Search in collection'),
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
