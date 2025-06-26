import 'package:saviaqua/features/home/model/junta/junta_model.dart';

class JuntaResponse {
  final List<JuntaModel> value;
  final bool success;

  JuntaResponse({
    required this.value,
    required this.success,
  });

  factory JuntaResponse.fromJson(Map<String, dynamic> json) {
    return JuntaResponse(
      value: (json['value'] as List)
          .map((item) => JuntaModel.fromJson(item))
          .toList(),
      success: json['success'] ?? false,
    );
  }
}
