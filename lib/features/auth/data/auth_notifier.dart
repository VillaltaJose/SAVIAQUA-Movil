import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthNotifier extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  String? _token;
  Map<String, dynamic>? _user;

  bool get isLoggedIn => _token != null;
  String? get token => _token;
  Map<String, dynamic>? get user => _user;

  AuthNotifier() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    _token = await _storage.read(key: 'session_token');
    notifyListeners();
  }

  Future<void> login(String token, Map<String, dynamic> user) async {
    await _storage.write(key: 'session_token', value: token);
    await _storage.write(key: 'session_user', value: jsonEncode(user));

    _token = token;
    _user = user;
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.delete(key: 'session_token');
    await _storage.delete(key: 'session_user');
    _token = null;
    _user = null;
    notifyListeners();
  }
}
