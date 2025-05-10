import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:knowledge_assistant/services/auth_token_storage.dart';

import '../models/chat_message.dart';

class ChatRepository {
  final String baseUrl;
  final AuthTokenStorage tokenStorage = AuthTokenStorage();

  ChatRepository({required this.baseUrl});

  Future<ChatMessage> askQuestion({
    required String collectionId,
    required String question,
  }) async {
    final token = await tokenStorage.getToken();
    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/collections/$collectionId/chat'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'question': question}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ChatMessage.fromJson(data);
    } else {
      throw Exception(
        'Request error: ${response.statusCode} — ${response.body}',
      );
    }
  }

  Future<List<ChatMessage>> getChatHistory(String collectionId) async {
    final token = await tokenStorage.getToken();
    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/collections/$collectionId/chat/history'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((messageJson) => ChatMessage.fromJson(messageJson))
          .toList();
    } else {
      throw Exception('Error loading chat history: ${response.statusCode}');
    }
  }

  Future<void> deleteMessage({
    required String collectionId,
    required String messageId,
  }) async {
    final token = await tokenStorage.getToken();
    if (token == null) throw Exception('User is not authenticated');

    final response = await http.delete(
      Uri.parse('$baseUrl/collections/$collectionId/chat/$messageId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 204) {
      throw Exception('Error message deleting: ${response.statusCode}');
    }
  }

  Future<void> deleteHistory(String collectionId) async {
    final token = await tokenStorage.getToken();
    if (token == null) throw Exception('User is not authenticated');

    final response = await http.delete(
      Uri.parse('$baseUrl/collections/$collectionId/chat/history'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 204) {
      throw Exception('Error history deleting');
    }
  }

  Future<ChatMessage> updateMessage({
    required String collectionId,
    required String messageId,
    required String question,
    required String answer,
  }) async {
    final token = await tokenStorage.getToken();
    if (token == null) throw Exception('User is not authenticated');

    final response = await http.patch(
      Uri.parse('$baseUrl/collections/$collectionId/chat/$messageId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'question': question, 'answer': answer}),
    );

    if (response.statusCode == 200) {
      return ChatMessage.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Update message error');
    }
  }
}
