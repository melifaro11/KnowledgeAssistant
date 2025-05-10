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
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final msg = state.messages[index];
                      return ListTile(
                        title: Text(msg.answer),
                        subtitle: Text(
                          'Источник: ${msg.sources ?? "неизвестно"}',
                          style: TextStyle(fontSize: 12),
                        ),
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
