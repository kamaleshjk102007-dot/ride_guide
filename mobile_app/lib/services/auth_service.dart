import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/user_session.dart';

class AuthService {
  AuthService({this.baseUrl = AppConfig.apiBaseUrl});

  final String baseUrl;
  static const Duration _requestTimeout = Duration(seconds: 25);

  Future<void> warmUpServer() async {
    try {
      await http.get(Uri.parse('$baseUrl/health')).timeout(const Duration(seconds: 20));
    } catch (_) {
      // Best-effort ping to wake sleeping hosted backends.
    }
  }

  Future<UserSession> login({
    required String email,
    required String password,
  }) async {
    await warmUpServer();

    final response = await http
        .post(
          Uri.parse('$baseUrl/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(_requestTimeout);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      throw Exception(data['message'] ?? 'Login failed.');
    }
    final user = data['user'] as Map<String, dynamic>;

    return UserSession(
      token: data['token'] ?? '',
      role: user['role'] ?? 'visitor',
      userId: user['_id'] ?? '',
      name: user['name'] ?? '',
      email: user['email'] ?? '',
    );
  }

  Future<UserSession> register({
    required String name,
    required String email,
    required String phone,
    required int age,
    required String password,
  }) async {
    await warmUpServer();

    final response = await http
        .post(
          Uri.parse('$baseUrl/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': name,
            'email': email,
            'phone': phone,
            'age': age,
            'password': password,
          }),
        )
        .timeout(_requestTimeout);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      throw Exception(data['message'] ?? 'Registration failed.');
    }
    final user = data['user'] as Map<String, dynamic>;

    return UserSession(
      token: data['token'] ?? '',
      role: user['role'] ?? 'visitor',
      userId: user['_id'] ?? '',
      name: user['name'] ?? '',
      email: user['email'] ?? '',
    );
  }
}
