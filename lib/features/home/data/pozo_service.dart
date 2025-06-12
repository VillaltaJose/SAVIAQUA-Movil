  import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:saviaqua/features/home/model/pozo_model.dart';
import 'package:saviaqua/features/home/model/pozo_response.dart';
import '../../../core/services/http_client.dart';

class PozoService {
  final http.Client _client = httpClient;

  Future<List<PozoModel>> getPozos() async {
    final response = await _client.get(Uri.parse('/pozos'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final parsed = PozoResponse.fromJson(data);
      return parsed.value;
    } else {
      throw Exception('Error al obtener los pozos'
          ' (${response.statusCode}): ${response.reasonPhrase}');
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

}
