import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/services/http_client.dart';

class AuthService {
  final _client = httpClient;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _client.post(
      Uri.parse('/autenticacion'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': email, 'clave': password}),
    );

    final json = jsonDecode(response.body);

    if (json['success'] == true) {
      final value = json['value'];
      return {'token': value['jwt'], 'perfilUsuario': value['perfilUsuario']};
    } else {
      final messages = json['messages'];
      throw Exception(messages.map((m) => m['code']).join('\n'));
    }
  }

  Future<void> logout() async {
    await secureStorage.delete(key: 'session_token');
    await secureStorage.delete(key: 'session_user');
  }

  Future<bool> isLoggedIn() async {
    final token = await secureStorage.read(key: 'session_token');
    return token != null;
  }

  Future<Map<String, dynamic>?> getUser() async {
    final raw = await secureStorage.read(key: 'session_user');
    return raw != null ? jsonDecode(raw) : null;
  }

  Future<String?> getToken() async {
    return await secureStorage.read(key: 'session_token');
  }

  Future<void> clearSession() async {
    await secureStorage.deleteAll();
  }
}
