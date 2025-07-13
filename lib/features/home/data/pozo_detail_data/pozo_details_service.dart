import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:saviaqua/features/home/model/pozo_details/pozo_details_model.dart';
import 'package:saviaqua/features/home/model/pozo_details/pozo_details_response.dart';
import '../../../../core/services/http_client.dart';

class PozoDetailsService {
  final http.Client _client = httpClient;

  Future<List<PozoDetailsModel>> getMeasurements(
    Map<String, String> filtros,
  ) async {
    final uri = Uri.parse('/pozos/mediciones');

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(filtros),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final parsed = PozoDetailsResponse.fromJson(data);
      return parsed.value;
    } else {
      throw Exception(
        'Error al obtener mediciones'
        ' (${response.statusCode}): ${response.reasonPhrase}',
      );
    }
  }

  Future<PozoDetailsModel> getMeasurementByPozoId(int codigoPozo) async {
  final uri = Uri.parse('pozos/$codigoPozo/mediciones/actualidad');

  final response = await _client.post(
    uri,
    headers: {'Content-Type': 'application/json'},
  );

print('Response status: ${response.statusCode}');
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final parsed = PozoDetailsSingleResponse.fromJson(data);
    print('Parsed response: $parsed');
    print('Measurement value: ${parsed.value}');
    return parsed.value;
  } else {
    throw Exception(
      'Error al obtener la medición'
      ' (${response.statusCode}): ${response.reasonPhrase}',
    );
  }
}

}
