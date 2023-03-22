// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';
import 'package:mobile/shared/models/User/user_tokens_model.dart';

class RegisterResponse {
  final String message;
  final bool success;
  final UserTokensModel content;

  RegisterResponse({
    required this.message,
    required this.success,
    required this.content,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'message': message,
      'success': success,
      'content': content.toMap(),
    };
  }

  factory RegisterResponse.fromMap(Map<String, dynamic> map) {
    return RegisterResponse(
      message: map['message'] as String,
      success: map['success'] as bool,
      content: UserTokensModel.fromMap(map['content'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      RegisterResponse(
          content: UserTokensModel.fromJson(json['content']),
          message: json['message'],
          success: json['success']);

  @override
  String toString() =>
      '{ message: $message, success: $success, content: $content }';
}
