import 'package:saviaqua/features/home/model/pozo_details/pozo_details_model.dart';

class PozoDetailsResponse {
  final List<PozoDetailsModel> value;
  final bool success;
  final List<String> messages;

  PozoDetailsResponse({
    required this.value,
    required this.success,
    required this.messages,
  });

  factory PozoDetailsResponse.fromJson(Map<String, dynamic> json) {
    return PozoDetailsResponse(
      value: (json['value'] as List)
          .map((e) => PozoDetailsModel.fromJson(e))
          .toList(),
      success: json['success'] ?? false,
      messages: List<String>.from(json['messages'] ?? []),
    );
  }
}
