import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:saviaqua/features/home/model/junta/Junta_DTO.dart';
import 'package:saviaqua/features/home/model/junta/junta_model.dart';
import 'package:saviaqua/features/home/model/junta/junta_response.dart';
import '../../../../core/services/http_client.dart';

class JuntaService {
  final http.Client _client = httpClient;

  Future<List<JuntaModel>> getJuntas() async {
    final response = await _client.get(Uri.parse('/juntas'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final parsed = JuntaResponse.fromJson(data);
      return parsed.value;
    } else {
      throw Exception(
        'Error al obtener las juntas'
        ' (${response.statusCode}): ${response.reasonPhrase}',
      );
    }
  }


  Future<List<JuntaModel>> getJuntasFiltrados(Map<String, String> filtros) async {
    final uri = Uri.parse('/juntas').replace(queryParameters: filtros);
    final response = await _client.get(uri);

    print('filtros: $filtros');
    print('url: $uri');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final parsed = JuntaResponse.fromJson(data);
      return parsed.value;
    } else {
      throw Exception('Error al obtener juntas filtradas');
    }
  }

  Future<void> createJunta(CreateJuntaDTO dto) async {
  final response = await _client.post(
    Uri.parse('/juntas'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(dto.toJson()),
  );


  if (response.statusCode != 200 && response.statusCode != 201) {
    throw Exception('Error al crear pozo: ${response.body}');
  }else {
    print('Pozo creado: ${jsonDecode(response.body)}');
    print('pozo creado: ${dto.toJson()}');
  }
}

}
