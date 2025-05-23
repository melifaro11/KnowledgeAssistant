import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:knowledge_assistant/models/source.dart';
import 'package:knowledge_assistant/models/source_state.dart';
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

  Future<Collection> addFileSource(
    String collectionId,
    String name,
    PlatformFile file,
  ) async {
    final token = await tokenStorage.getToken();
    final uri = Uri.parse('$baseUrl/collections/$collectionId/sources/file');
    final request =
        http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['name'] = name
          ..files.add(
            http.MultipartFile.fromBytes(
              'file',
              file.bytes!,
              filename: file.name,
            ),
          );
    final streamed = await request.send();
    if (streamed.statusCode != 201) {
      throw Exception(
        'Error adding file source: ${await streamed.stream.bytesToString()}',
      );
    }

    return getCollectionById(collectionId);
  }

  Future<Collection> addGitSource(
    String collectionId,
    String name,
    String gitUrl, {
    Map<String, dynamic> config = const {},
  }) async {
    final token = await tokenStorage.getToken();
    final response = await httpClient.post(
      Uri.parse('$baseUrl/collections/$collectionId/sources/git'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name, 'location': gitUrl, 'config': config}),
    );
    if (response.statusCode != 201) {
      throw Exception('Error adding git source: ${response.body}');
    }
    return getCollectionById(collectionId);
  }

  Future<Collection> addUrlSource(
    String collectionId,
    String name,
    String url, {
    Map<String, dynamic> config = const {},
  }) async {
    final token = await tokenStorage.getToken();
    final response = await httpClient.post(
      Uri.parse('$baseUrl/collections/$collectionId/sources/url'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name, 'location': url, 'config': config}),
    );
    if (response.statusCode != 201) {
      throw Exception('Error adding url source: ${response.body}');
    }
    return getCollectionById(collectionId);
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

  Future<SourceStatus> fetchSourceStatus(
    String collectionId,
    String sourceId,
  ) async {
    final token = await tokenStorage.getToken();
    final resp = await httpClient.get(
      Uri.parse('$baseUrl/collections/$collectionId/sources/$sourceId/status'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resp.statusCode != 200) {
      throw Exception('Cannot fetch source status: ${resp.body}');
    }
    final json = jsonDecode(resp.body) as Map<String, dynamic>;

    return SourceStatus.fromJson(json, sourceId);
  }
}
