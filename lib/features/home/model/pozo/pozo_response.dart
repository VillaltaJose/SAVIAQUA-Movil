import 'package:saviaqua/features/home/model/pozo/pozo_metada.dart';
import 'package:saviaqua/features/home/model/pozo/pozo_model.dart';

class PozoResponse {
  final List<PozoModel> value;
  final Metadata metadata;
  final bool success;
  final List<String> messages;

  PozoResponse({
    required this.value,
    required this.metadata,
    required this.success,
    required this.messages,
  });

  factory PozoResponse.fromJson(Map<String, dynamic> json) {
    return PozoResponse(
      value: List<PozoModel>.from(json['value'].map((e) => PozoModel.fromJson(e))),
      metadata: Metadata.fromJson(json['metadata']),
      success: json['success'],
      messages: List<String>.from(json['messages']),
    );
  }
}
