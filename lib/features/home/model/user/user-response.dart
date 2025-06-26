import 'package:saviaqua/features/home/model/user/user-model.dart';

class UserResponse {
  final List<UserModel> value;
  final bool success;
  final List<String> messages;

  UserResponse({
    required this.value,
    required this.success,
    required this.messages,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      value: (json['value'] as List).map((e) => UserModel.fromJson(e)).toList(),
      success: json['success'],
      messages: List<String>.from(json['messages']),
    );
  }
}
