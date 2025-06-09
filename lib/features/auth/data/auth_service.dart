import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/http_client.dart';

class AuthService {
  final _client = httpClient;

  Future<void> login(String email, String password) async {
  final response = await _client.post(
    Uri.parse('/autenticacion'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'correo': email, 'clave': password}),
  );

  final json = jsonDecode(response.body);

  if (json['success'] == true) {
    final value = json['value'];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_token', value['jwt']);
    await prefs.setString('session_user', jsonEncode(value['user']));
  } else {
    final messages = json['messages'];
    throw Exception(messages.map((m) => m['code']).join('\n'));
  }
}


  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_token');
    await prefs.remove('session_user');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('session_token');
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('session_user');
    return raw != null ? jsonDecode(raw) : null;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('session_token');
  }
}
