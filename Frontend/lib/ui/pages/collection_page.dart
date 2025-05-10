import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge_assistant/bloc/collections_bloc.dart';
import 'package:knowledge_assistant/bloc/events/collections_event.dart';
import 'package:knowledge_assistant/bloc/states/collections_state.dart';
import 'package:knowledge_assistant/repositories/collections_repository.dart';

class CollectionPage extends StatefulWidget {
  final String collectionId;

  const CollectionPage({super.key, required this.collectionId});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final Set<String> _indexingSources = {};

  @override
  void initState() {
    super.initState();
    context.read<CollectionsBloc>().add(
      LoadCollectionById(widget.collectionId),
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
                  try {
                    context.read<CollectionsBloc>().add(
                      AddSourceToCollection(
                        collectionId: widget.collectionId,
                        name: nameController.text,
                        type: type,
                        location: locationController.text,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Ошибка добавления источника: $e'),
                      ),
                    );
                  }
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
      body: BlocBuilder<CollectionsBloc, CollectionsState>(
        builder: (context, state) {
          if (state is CollectionsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CollectionsLoaded) {
            final collection = state.collections.firstWhere(
              (c) => c.id == widget.collectionId,
            );
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  collection.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text('Поиск по коллекции'),
                  onPressed: () {
                    GoRouter.of(context).push('/chat/${widget.collectionId}');
                  },
                ),
                const SizedBox(height: 16),
                ...collection.sources.map(
                  (s) => ListTile(
                    title: Text(s.name),
                    subtitle: Text('${s.type.name} | ${s.location ?? "—"}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (s.lastError != null)
                          Tooltip(
                            message: s.lastError!,
                            child: const Icon(Icons.error, color: Colors.red),
                          )
                        else if (s.isIndexed)
                          const Icon(Icons.check_circle, color: Colors.green)
                        else
                          const Icon(Icons.hourglass_empty, color: Colors.grey),
                        const SizedBox(width: 8),
                        _indexingSources.contains(s.id)
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : IconButton(
                              icon: const Icon(Icons.refresh),
                              tooltip: 'Reindex',
                              onPressed: () async {
                                setState(() {
                                  _indexingSources.add(s.id);
                                });

                                try {
                                  final updatedSource = await context
                                      .read<CollectionsRepository>()
                                      .reindexSource(widget.collectionId, s.id);
                                  context.read<CollectionsBloc>().add(
                                    UpdateSourceInCollection(
                                      widget.collectionId,
                                      updatedSource,
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Ошибка индексации: $e'),
                                    ),
                                  );
                                } finally {
                                  setState(() {
                                    _indexingSources.remove(s.id);
                                  });
                                }
                              },
                            ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.grey),
                          tooltip: 'Delete',
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder:
                                  (_) => AlertDialog(
                                    title: const Text('Delete source?'),
                                    content: const Text(
                                      'Вы уверены, что хотите удалить этот источник?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                            );

                            if (confirmed == true) {
                              context.read<CollectionsBloc>().add(
                                DeleteSourceFromCollection(
                                  widget.collectionId,
                                  s.id,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (state is CollectionsError) {
            return Center(child: Text(state.message));
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
