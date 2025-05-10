import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowledge_assistant/bloc/chat_bloc.dart';
import 'package:knowledge_assistant/bloc/events/chat_event.dart';
import 'package:knowledge_assistant/bloc/states/chat_state.dart';
import 'package:knowledge_assistant/ui/widgets/chat_message_widget.dart';
import 'package:knowledge_assistant/ui/widgets/textfield_decorated.dart';

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
    /*
    await Future.delayed(const Duration(milliseconds: 100));
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    */
  }

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(LoadChatHistory(widget.collectionId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search in collection')),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ChatLoaded) {
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final msg = state.messages[index];
                      return ChatMessageWidget(msg: msg);
                    },
                  );
                } else if (state is ChatError) {
                  return Center(child: Text(state.message));
                } else {
                  return const Center(child: Text('Loading...'));
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
            child: TextFieldDecorated(
              controller: _controller,
              minLines: 1,
              maxLines: 2,
              suffix: IconButton(
                icon: const Icon(Icons.send),
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
            ),
          ),
        ],
      ),
    );
  }
}
