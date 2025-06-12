
import 'package:saviaqua/features/home/model/place_model.dart';

class ResponseLugar {
  final List<LugarModel> value;
  final bool success;

  ResponseLugar({required this.value, required this.success});

  factory ResponseLugar.fromJson(Map<String, dynamic> json) {
    return ResponseLugar(
      value: List<LugarModel>.from(
        json['value'].map((e) => LugarModel.fromJson(e)),
      ),
      success: json['success'],
    );
  }
}
