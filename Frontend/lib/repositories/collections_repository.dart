import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:knowledge_assistant/services/auth_token_storage.dart';
import '../models/collection.dart';

class CollectionsRepository {
  final String baseUrl;
  final http.Client httpClient;
  final AuthTokenStorage tokenStorage = AuthTokenStorage();

  CollectionsRepository({required this.baseUrl, http.Client? httpClient})
    : httpClient = httpClient ?? http.Client();

  Future<List<Collection>> fetchCollections() async {
    final token = await tokenStorage.getToken();
    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await httpClient.get(
      Uri.parse('$baseUrl/collections'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Ошибка загрузки коллекций');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Collection.fromJson(json)).toList();
  }

  Future<Collection> createCollection(String name) async {
    final token = await tokenStorage.getToken();
    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await httpClient.post(
      Uri.parse('$baseUrl/collections'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name}),
    );

    if (response.statusCode != 201) {
      throw Exception('Ошибка создания коллекции');
    }

    final data = jsonDecode(response.body);
    return Collection.fromJson(data);
  }

  Future<void> deleteCollection(String id) async {
    final token = await tokenStorage.getToken();
    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await httpClient.delete(
      Uri.parse('$baseUrl/collections/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 204) {
      throw Exception('Ошибка удаления коллекции');
    }
  }

  Future<Collection> getCollectionById(String id) async {
    final token = await tokenStorage.getToken();
    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await httpClient.get(
      Uri.parse('$baseUrl/collections/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Коллекция не найдена');
    }

    final data = jsonDecode(response.body);
    return Collection.fromJson(data);
  }
}
