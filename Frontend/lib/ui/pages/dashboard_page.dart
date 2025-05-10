import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge_assistant/bloc/collections_bloc.dart';
import 'package:knowledge_assistant/bloc/events/collections_event.dart';
import 'package:knowledge_assistant/bloc/states/collections_state.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My collections'),
        elevation: 10,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<CollectionsBloc>().add(LoadCollections());
            },
          ),
        ],
      ),
      body: BlocBuilder<CollectionsBloc, CollectionsState>(
        builder: (context, state) {
          if (state is CollectionsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CollectionsLoaded) {
            if (state.collections.isEmpty) {
              return const Center(child: Text('No collections'));
            }
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: ListView.builder(
                itemCount: state.collections.length,
                itemBuilder: (context, index) {
                  final collection = state.collections[index];
                  return ListTile(
                    title: Text(collection.name),
                    trailing: SizedBox(
                      width: 80,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              context.push('/collection/${collection.id}');
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder:
                                    (_) => AlertDialog(
                                      title: const Text('Delete collection?'),
                                      content: Text(
                                        'Are you sure you want to delete the collection "${collection.name}"?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                              );

                              if (confirmed == true) {
                                context.read<CollectionsBloc>().add(
                                  DeleteCollection(collection.id),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    onTap:
                        () =>
                            GoRouter.of(context).push('/chat/${collection.id}'),
                  );
                },
              ),
            );
          } else if (state is CollectionsError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text('Collections not loaded'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('New collection'),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Collection name'),
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isNotEmpty) {
                    context.read<CollectionsBloc>().add(CreateCollection(name));
                    context.pop();
                  }
                },
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }
}
