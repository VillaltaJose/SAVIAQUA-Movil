import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:saviaqua/features/home/model/response_place.dart';
import '../../../core/services/http_client.dart';

class LocationService {
  final http.Client _client = httpClient;

  Future<ResponseLugar> getProvincias() async {
    final res = await _client.get(Uri.parse('/lugares/provincias'));
    if (res.statusCode != 200) throw Exception('Error al cargar provincias');
    return ResponseLugar.fromJson(jsonDecode(res.body));
  }

  Future<ResponseLugar> getCiudades(int codigoProvincia) async {
    final res = await _client.get(Uri.parse('/lugares/provincias/$codigoProvincia/ciudades'));
    if (res.statusCode != 200) throw Exception('Error al cargar ciudades');
    return ResponseLugar.fromJson(jsonDecode(res.body));
  }

  Future<ResponseLugar> getParroquias(int codigoProvincia, int codigoCiudad) async {
    final res = await _client.get(Uri.parse(
        '/lugares/provincias/$codigoProvincia/ciudades/$codigoCiudad/parroquias'));
    if (res.statusCode != 200) throw Exception('Error al cargar parroquias');
    return ResponseLugar.fromJson(jsonDecode(res.body));
  }
}
