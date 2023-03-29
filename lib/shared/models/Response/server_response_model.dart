// ignore_for_file: public_member_api_docs, sort_constructors_first

class ServerResponse {
  final String message;
  final bool success;
  final bool? content;

  ServerResponse({required this.message, required this.success, this.content});

  factory ServerResponse.fromJson(Map<String, dynamic> json) => ServerResponse(
      message: json['message'],
      success: json['success'],
      content: json['content']);

  @override
  String toString() =>
      '{ message: $message, success: $success, content: $content }';
}
