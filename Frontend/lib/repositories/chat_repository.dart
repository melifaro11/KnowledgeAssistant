import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

class ChatRepository {
  final String baseUrl;

  ChatRepository({required this.baseUrl});

  /// Отправка вопроса в коллекцию и получение ответа
  Future<ChatMessage> askQuestion({
    required String collectionId,
    required String question,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/collections/$collectionId/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'question': question}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ChatMessage.fromJson(data);
    } else {
      throw Exception(
          'Ошибка запроса: ${response.statusCode} — ${response.body}');
    }
  }

  /// Получение истории сообщений по коллекции
  Future<List<ChatMessage>> getChatHistory(String collectionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/collections/$collectionId/chat/history'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((messageJson) => ChatMessage.fromJson(messageJson))
          .toList();
    } else {
      throw Exception(
          'Не удалось загрузить историю чата: ${response.statusCode}');
    }
  }
}
