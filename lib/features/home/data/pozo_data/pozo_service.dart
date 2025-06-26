import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:saviaqua/features/home/model/pozo/pozo_DTO.dart';
import 'package:saviaqua/features/home/model/pozo/pozo_model.dart';
import 'package:saviaqua/features/home/model/pozo/pozo_response.dart';
import '../../../../core/services/http_client.dart';

class PozoService {
  final http.Client _client = httpClient;

  Future<List<PozoModel>> getPozos() async {
    final response = await _client.get(Uri.parse('/pozos'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final parsed = PozoResponse.fromJson(data);
      return parsed.value;
    } else {
      throw Exception(
        'Error al obtener los pozos'
        ' (${response.statusCode}): ${response.reasonPhrase}',
      );
    }
  }

Future<PozoModel?> getPozoById(int id) async {
  final response = await _client.get(Uri.parse('/pozos/$id'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final pozoJson = data['value'];
    return PozoModel.fromJson(pozoJson);
  } else {
    throw Exception(
      'Error al obtener el pozo con ID $id '
      '(${response.statusCode}): ${response.reasonPhrase}',
    );
  }
}


  Future<List<PozoModel>> getPozosFiltrados(Map<String, String> filtros) async {
    final uri = Uri.parse('/pozos').replace(queryParameters: filtros);
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final parsed = PozoResponse.fromJson(data);
      return parsed.value;
    } else {
      throw Exception('Error al obtener pozos filtrados');
    }
  }

  Future<void> createPozo(CreatePozoDTO dto) async {
  final response = await _client.post(
    Uri.parse('/pozos'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(dto.toJson()),
  );


  if (response.statusCode != 200 && response.statusCode != 201) {
    throw Exception('Error al crear pozo: ${response.body}');
  }
}

}
