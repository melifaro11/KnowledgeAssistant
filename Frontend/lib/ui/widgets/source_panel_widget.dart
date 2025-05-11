import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowledge_assistant/bloc/collection_detail_bloc.dart';
import 'package:knowledge_assistant/bloc/events/collection_detail_event.dart';
import 'package:knowledge_assistant/models/source.dart';
import 'package:knowledge_assistant/repositories/collections_repository.dart';

class SourcePanel extends StatefulWidget {
  final Source source;
  final String collectionId;

  const SourcePanel({
    super.key,
    required this.source,
    required this.collectionId,
  });

  @override
  State<SourcePanel> createState() => _SourcePanelState();
}

class _SourcePanelState extends State<SourcePanel> {
  bool _isIndexing = false;

  @override
  Widget build(BuildContext context) {
    final repo = context.read<CollectionsRepository>();
    final bloc = context.read<CollectionDetailBloc>();
    final messenger = ScaffoldMessenger.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.indigo.shade400.withAlpha(20),
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (widget.source.type.name == 'url')
              Image.asset("assets/images/source_url.png", height: 42),
            if (widget.source.type.name == 'file')
              Image.asset("assets/images/source_file.png", height: 42),
            if (widget.source.type.name == 'git')
              Image.asset("assets/images/source_git.png", height: 42),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.source.name,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.source.location ?? "—",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.source.lastError != null)
                  const Icon(Icons.error, color: Colors.red)
                else if (widget.source.isIndexed)
                  const Icon(Icons.check_circle, color: Colors.green)
                else
                  const Icon(Icons.hourglass_empty, color: Colors.grey),

                if (widget.source.lastError != null)
                  Text(
                    widget.source.lastError ?? "",
                    maxLines: 2,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(width: 8),
                _isIndexing
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Reindex',
                      onPressed:
                          () => _onReindexPressed(
                            repo: repo,
                            bloc: bloc,
                            messenger: messenger,
                          ),
                    ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.grey),
                  tooltip: 'Delete',
                  onPressed: () => _onDeletePressed(bloc: bloc),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onReindexPressed({
    required CollectionsRepository repo,
    required CollectionDetailBloc bloc,
    required ScaffoldMessengerState messenger,
  }) {
    setState(() => _isIndexing = true);

    repo
        .reindexSource(widget.collectionId, widget.source.id)
        .then((updatedSource) {
          bloc.add(
            UpdateSourceInCollection(widget.collectionId, updatedSource),
          );
        })
        .catchError((e) {
          messenger.showSnackBar(SnackBar(content: Text('Indexing error: $e')));
        })
        .whenComplete(() {
          if (!mounted) return;
          setState(() => _isIndexing = false);
        });
  }

  void _onDeletePressed({required CollectionDetailBloc bloc}) {
    final dialogContext = context;
    showDialog<bool>(
      context: dialogContext,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete source?'),
            content: const Text('Are you sure you want to delete this source?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    ).then((confirmed) {
      if (confirmed == true) {
        bloc.add(
          DeleteSourceFromCollection(widget.collectionId, widget.source.id),
        );
      }
    });
  }
}
