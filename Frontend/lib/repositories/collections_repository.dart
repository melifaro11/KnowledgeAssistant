import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:knowledge_assistant/models/source.dart';
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
      throw Exception('Collection loading error');
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
      throw Exception('Collection creating error');
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
      throw Exception('Collection deleting error');
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
      throw Exception('Collection not found');
    }

    return Collection.fromJson(jsonDecode(response.body));
  }

  Future<Collection> addSourceToCollection(
    String collectionId,
    String name,
    String type,
    String? location,
  ) async {
    final token = await tokenStorage.getToken();
    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await httpClient.post(
      Uri.parse('$baseUrl/collections/$collectionId/sources'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name, 'type': type, 'location': location}),
    );

    if (response.statusCode != 201) {
      throw Exception('Error adding source');
    }

    final collection = await getCollectionById(collectionId);

    return collection;
  }

  Future<Source> reindexSource(String collectionId, String sourceId) async {
    final token = await tokenStorage.getToken();
    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await httpClient.post(
      Uri.parse('$baseUrl/collections/$collectionId/sources/$sourceId/index'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Source indexing error: ${response.body}');
    }

    return Source.fromJson(jsonDecode(response.body));
  }

  Future<Collection> deleteSourceFromCollection(
    String collectionId,
    String sourceId,
  ) async {
    final token = await tokenStorage.getToken();
    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await httpClient.delete(
      Uri.parse('$baseUrl/collections/$collectionId/sources/$sourceId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 204) {
      throw Exception('Source deleting error');
    }

    return await getCollectionById(collectionId);
  }
}
