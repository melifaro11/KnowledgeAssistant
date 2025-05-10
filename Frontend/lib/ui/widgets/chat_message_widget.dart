import 'package:flutter/material.dart';
import 'package:knowledge_assistant/models/chat_message.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage msg;

  const ChatMessageWidget({super.key, required this.msg});

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
            Text(
              msg.question,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
