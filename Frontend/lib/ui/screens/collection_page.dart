import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge_assistant/bloc/collections_bloc.dart';
import 'package:knowledge_assistant/bloc/events/collections_event.dart';
import 'package:knowledge_assistant/bloc/states/collections_state.dart';

class CollectionsPage extends StatelessWidget {
  const CollectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Collections')),
      body: BlocBuilder<CollectionsBloc, CollectionsState>(
        builder: (context, state) {
          if (state is CollectionsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CollectionsLoaded) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: state.collections.length,
                    itemBuilder: (context, index) {
                      final collection = state.collections[index];
                      return ListTile(
                        title: Text(collection.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            context.read<CollectionsBloc>().add(
                              DeleteCollection(collection.id),
                            );
                          },
                        ),
                        onTap: () {
                          // Навигация к деталям коллекции:
                          // Navigator.push(...);
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _showCreateCollectionDialog(context);
                    },
                    child: const Text('Create collection'),
                  ),
                ),
              ],
            );
          } else if (state is CollectionsError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text('No data'));
          }
        },
      ),
    );
  }

  void _showCreateCollectionDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('New collection'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Enter name'),
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = controller.text.trim();
                  if (name.isNotEmpty) {
                    context.read<CollectionsBloc>().add(CreateCollection(name));
                  }
                  Navigator.pop(context);
                },
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }
}
