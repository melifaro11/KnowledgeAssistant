import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/collection.dart';

class CollectionsRepository {
  final String baseUrl;
  final http.Client httpClient;

  CollectionsRepository({
    required this.baseUrl,
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();

  Future<List<Collection>> fetchCollections() async {
    final response = await httpClient.get(Uri.parse('$baseUrl/collections'));

    if (response.statusCode != 200) {
      throw Exception('Ошибка загрузки коллекций');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Collection.fromJson(json)).toList();
  }

  Future<Collection> createCollection(String name) async {
    final response = await httpClient.post(
      Uri.parse('$baseUrl/collections'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );

    if (response.statusCode != 201) {
      throw Exception('Ошибка создания коллекции');
    }

    final data = jsonDecode(response.body);
    return Collection.fromJson(data);
  }

  Future<void> deleteCollection(String id) async {
    final response =
    await httpClient.delete(Uri.parse('$baseUrl/collections/$id'));

    if (response.statusCode != 204) {
      throw Exception('Ошибка удаления коллекции');
    }
  }

  Future<Collection> getCollectionById(String id) async {
    final response =
    await httpClient.get(Uri.parse('$baseUrl/collections/$id'));

    if (response.statusCode != 200) {
      throw Exception('Коллекция не найдена');
    }

    final data = jsonDecode(response.body);
    return Collection.fromJson(data);
  }
}
