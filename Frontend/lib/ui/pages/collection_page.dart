import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge_assistant/bloc/collection_detail_bloc.dart';
import 'package:knowledge_assistant/bloc/events/collection_detail_event.dart';
import 'package:knowledge_assistant/bloc/states/collection_detail_state.dart';
import 'package:knowledge_assistant/ui/widgets/elevated_icon_button.dart';
import 'package:knowledge_assistant/ui/widgets/inline_source_panel.dart';
import 'package:knowledge_assistant/ui/widgets/source_panel_widget.dart';

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
      appBar: AppBar(title: const Text('Collection'), elevation: 10),
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
                        vertical: 8,
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
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 10,
                              ),
                              child: InlineSourcePanel(
                                collectionId: widget.collectionId,
                                onDone: () {
                                  setState(() {
                                    _showInlinePanel = false;
                                  });
                                },
                              ),
                            ),
                          ),
                        //SizedBox(height: 16),
                        ElevatedIconButton(
                          width: 150,
                          icon:
                              _showInlinePanel
                                  ? const Icon(Icons.arrow_downward)
                                  : const Icon(Icons.add),
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
