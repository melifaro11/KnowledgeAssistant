import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowledge_assistant/bloc/chat_bloc.dart';
import 'package:knowledge_assistant/bloc/events/chat_event.dart';
import 'package:knowledge_assistant/models/chat_message.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage msg;

  final String collectionId;

  const ChatMessageWidget({
    super.key,
    required this.msg,
    required this.collectionId,
  });

  void _showEditDialog(BuildContext context, ChatMessage msg) {
    final questionCtrl = TextEditingController(text: msg.question);
    final answerCtrl = TextEditingController(text: msg.answer);

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Edit message'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: questionCtrl,
                  decoration: const InputDecoration(labelText: 'Request'),
                ),
                TextField(
                  controller: answerCtrl,
                  decoration: const InputDecoration(labelText: 'Response'),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Save'),
                onPressed: () {
                  context.read<ChatBloc>().add(
                    EditMessage(
                      collectionId: collectionId,
                      messageId: msg.id,
                      question: questionCtrl.text,
                      answer: answerCtrl.text,
                    ),
                  );
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.indigo.shade400.withAlpha(30),
            width: 3,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question
            Row(
              children: [
                Expanded(
                  child: Text(
                    msg.question,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black38,
                    ),
                  ),
                ),
                PopupMenuButton(
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: SizedBox(
                            width: 150,
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 10),
                                Text('Edit'),
                              ],
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: SizedBox(
                            width: 150,
                            child: Row(
                              children: [
                                Icon(Icons.delete),
                                SizedBox(width: 10),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ),
                      ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditDialog(context, msg);
                    } else if (value == 'delete') {
                      context.read<ChatBloc>().add(
                        DeleteMessage(
                          collectionId: collectionId,
                          messageId: msg.id,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),
            Divider(color: Colors.indigo.shade400.withAlpha(50)),
            const SizedBox(height: 4),

            // Answer
            Text(msg.answer, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Divider(color: Colors.indigo.shade400.withAlpha(50)),
            const SizedBox(height: 4),

            if (msg.sources.isNotEmpty) ...[
              const Text(
                'Sources',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children:
                    msg.sources.map((s) {
                      final label = s.url ?? '${s.title} (local)';
                      return Chip(
                        label: Text(
                          label,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.indigo.shade400.withAlpha(20),
                      );
                    }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
