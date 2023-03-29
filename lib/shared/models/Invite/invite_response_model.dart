// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:mobile/shared/models/Invite/invite_content_model.dart';

class InviteResponse {
  final String message;
  final bool success;
  final InviteContent content;

  InviteResponse({
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

  factory InviteResponse.fromMap(Map<String, dynamic> map) {
    return InviteResponse(
      message: map['message'] as String,
      success: map['success'] as bool,
      content: InviteContent.fromMap(map['content'] as Map<String, dynamic>),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory InviteResponse.fromJson(Map<String, dynamic> json) => InviteResponse(
      content: InviteContent.fromJson(json['content']),
      message: json['message'],
      success: json['success']);

  @override
  String toString() =>
      '{ message: $message, success: $success, content: $content }';
}
