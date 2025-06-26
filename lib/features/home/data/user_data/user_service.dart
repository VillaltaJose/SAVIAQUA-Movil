import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:saviaqua/core/services/http_client.dart';
import 'package:saviaqua/features/home/model/user/user-model.dart';
import 'package:saviaqua/features/home/model/user/user-response.dart';

class UserService {
  final http.Client _client = httpClient;

  Future<List<UserModel>> getUsers() async {
    final response = await _client.get(Uri.parse('/usuarios'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final parsed = UserResponse.fromJson(data);
      return parsed.value;
    } else {
      throw Exception(
        'Error al obtener los usuarios '
        '(${response.statusCode}): ${response.reasonPhrase}',
      );
    }
  }

  Future<List<UserModel>> getFilteredUsers(Map<String, String> filters) async {
    final uri = Uri.parse('/usuarios').replace(queryParameters: filters);
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final parsed = UserResponse.fromJson(data);
      return parsed.value;
    } else {
      throw Exception(
        'Error al obtener usuarios filtrados '
        '(${response.statusCode}): ${response.reasonPhrase}',
      );
    }
  }

  Future<UserModel?> getUserById(int id) async {
    final response = await _client.get(Uri.parse('/usuarios/$id'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data['value']);
    } else {
      throw Exception(
        'Error al obtener el usuario con ID $id '
        '(${response.statusCode}): ${response.reasonPhrase}',
      );
    }
  }
}
