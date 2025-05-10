import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowledge_assistant/bloc/chat_bloc.dart';
import 'package:knowledge_assistant/bloc/events/chat_event.dart';
import 'package:knowledge_assistant/bloc/states/chat_state.dart';

class ChatPage extends StatefulWidget {
  final String collectionId;

  const ChatPage({super.key, required this.collectionId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  Future<void> _scrollToEnd() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(LoadChatHistory(widget.collectionId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Поиск в коллекции')),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is ChatLoaded) {
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final msg = state.messages[index];
                      return ListTile(
                        title: Text(
                          msg.question,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(msg.answer),
                            if (msg.sources.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children:
                                    msg.sources.map((s) {
                                      final label =
                                          s.url != null
                                              ? s.title
                                              : '${s.title} (локально)';
                                      return Chip(
                                        label: Text(
                                          label,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        backgroundColor: Colors.grey.shade200,
                                      );
                                    }).toList(),
                              ),
                            ],
                          ],
                        ),
                        isThreeLine: true,
                      );
                    },
                  );
                } else if (state is ChatError) {
                  return Center(child: Text(state.message));
                } else {
                  return Center(child: Text('Введите вопрос для поиска'));
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Введите ваш вопрос...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final question = _controller.text.trim();
                    if (question.isNotEmpty) {
                      context.read<ChatBloc>().add(
                        SendMessage(
                          collectionId: widget.collectionId,
                          question: question,
                        ),
                      );
                      _controller.clear();

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToEnd();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
