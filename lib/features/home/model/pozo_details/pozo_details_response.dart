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
      value:
          (json['value'] as List)
              .map((e) => PozoDetailsModel.fromJson(e))
              .toList(),
      success: json['success'] ?? false,
      messages: List<String>.from(json['messages'] ?? []),
    );
  }
}

class PozoDetailsSingleResponse {
  final PozoDetailsModel value;
  final bool success;
  final List<String> messages;

  PozoDetailsSingleResponse({
    required this.value,
    required this.success,
    required this.messages,
  });

  factory PozoDetailsSingleResponse.fromJson(Map<String, dynamic> json) {
    return PozoDetailsSingleResponse(
      value: PozoDetailsModel.fromJson(json['value']),
      success: json['success'] ?? false,
      messages: List<String>.from(json['messages'] ?? []),
    );
  }
  
  @override
  String toString() {
    return 'PozoDetailsSingleResponse(value: $value, success: $success, messages: $messages)';
  }
}
