// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:mobile/shared/models/Invite/invite_answer_content_model.dart';

class InviteAnswerResponse {
  final String message;
  final bool success;
  final InviteAnswerContent content;

  InviteAnswerResponse({
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

  factory InviteAnswerResponse.fromMap(Map<String, dynamic> map) {
    return InviteAnswerResponse(
      message: map['message'] as String,
      success: map['success'] as bool,
      content:
          InviteAnswerContent.fromMap(map['content'] as Map<String, dynamic>),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory InviteAnswerResponse.fromJson(Map<String, dynamic> json) =>
      InviteAnswerResponse(
          content: InviteAnswerContent.fromJson(json['content']),
          message: json['message'],
          success: json['success']);

  @override
  String toString() =>
      '{ message: $message, success: $success, content: $content }';
}
