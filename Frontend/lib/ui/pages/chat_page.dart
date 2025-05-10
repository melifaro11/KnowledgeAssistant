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

  List<dynamic> _messages = [];
  bool _isSending = false;

  Future<void> _scrollToEnd() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!_scrollController.hasClients) return;
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
      appBar: AppBar(title: const Text('Search in collection')),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatLoaded) {
                  setState(() {
                    _messages = state.messages;
                    _isSending = false;
                  });
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToEnd();
                  });
                } else if (state is ChatError) {
                  setState(() {
                    _isSending = false;
                  });
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              builder: (context, state) {
                if (_messages.isEmpty && state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length + (_isSending ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < _messages.length) {
                      final msg = _messages[index];
                      return ChatMessageWidget(
                        msg: msg,
                        collectionId: widget.collectionId,
                      );
                    } else {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                  },
                );
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
                  if (question.isEmpty) return;

                  setState(() {
                    _isSending = true;
                  });

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToEnd();
                  });

                  context.read<ChatBloc>().add(
                    SendMessage(
                      collectionId: widget.collectionId,
                      question: question,
                    ),
                  );

                  _controller.clear();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
