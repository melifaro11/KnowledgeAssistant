import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthRepository {
  final String apiBaseUrl;

  AuthRepository({required this.apiBaseUrl});

  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Ошибка авторизации: ${response.body}');
    }
  }

  Future<User> register({
    required String email,
    required String password,
    String? name,
  }) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Ошибка регистрации: ${response.body}');
    }
  }

  Future<void> logout(String token) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/auth/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Ошибка выхода: ${response.body}');
    }
  }
}
