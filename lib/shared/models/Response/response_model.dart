// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ServerResponse<T> {
  final String message;
  final bool success;

  ServerResponse({
    required this.message,
    required this.success,
  });

  factory ServerResponse.fromMap(Map<String, dynamic> map) {
    return ServerResponse(
      message: map['message'] as String,
      success: map['success'] as bool,
    );
  }

  factory ServerResponse.fromJson(String source) =>
      ServerResponse.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
