import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../models/user.dart';

class RepositoryException implements Exception {
  final String message;

  RepositoryException(this.message);

  @override
  String toString() => message;
}

class AuthRepository {
  final String baseUrl;

  AuthRepository({required this.baseUrl});

  Future<User> login({required String email, required String password}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    debugPrint(response.statusCode.toString());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else if (response.statusCode == 401) {
      throw RepositoryException(jsonDecode(response.body)["detail"]);
    } else if (response.statusCode == 422) {
      throw RepositoryException(
        jsonDecode(response.body)["detail"][0]["ctx"]["reason"],
      );
    } else {
      throw Exception('Authorization error: ${response.body}');
    }
  }

  Future<User> register({
    required String email,
    required String password,
    String? name,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'name': name}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else if (response.statusCode == 400) {
      throw RepositoryException(jsonDecode(response.body)["detail"]);
    } else if (response.statusCode == 422) {
      throw RepositoryException(
        jsonDecode(response.body)["detail"][0]["ctx"]["reason"],
      );
    } else {
      throw Exception('Registration error: ${response.body}');
    }
  }

  Future<void> logout(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Logout error: ${response.body}');
    }
  }
}
