
class ChatSource {
  final String title;
  final String? url;
  final String? page;

  const ChatSource({
    required this.title,
    this.url,
    this.page,
  });

  factory ChatSource.fromJson(Map<String, dynamic> json) {
    return ChatSource(
      title: json['title'],
      url: json['url'],
      page: json['page'],
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'url': url,
    'page': page,
  };
}

class ChatMessage {
  final String id;
  final String question;
  final String answer;
  final List<ChatSource> sources;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.question,
    required this.answer,
    required this.sources,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, question, answer, sources, timestamp];

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
      sources: (json['sources'] as List<dynamic>)
          .map((source) => ChatSource.fromJson(source))
          .toList(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'answer': answer,
    'sources': sources.map((s) => s.toJson()).toList(),
    'timestamp': timestamp.toIso8601String(),
  };
}
