import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:saviaqua/core/services/http_client.dart';
import 'package:saviaqua/features/home/model/profile/profile-model.dart';

class ProfileService {
  final http.Client _client = httpClient;
  
  Future<ProfileModel?> getProfileProfile() async {
    final response = await _client.get(Uri.parse('/perfil'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ProfileModel.fromJson(data['value']);
    } else {
      throw Exception(
        'Error al obtener la información del perfil'
        '(${response.statusCode}): ${response.reasonPhrase}',
      );
    }
  }
}
