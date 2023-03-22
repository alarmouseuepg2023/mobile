// ignore_for_file: public_member_api_docs, sort_constructors_first

class ServerResponse {
  final String message;
  final bool success;

  ServerResponse({
    required this.message,
    required this.success,
  });

  factory ServerResponse.fromJson(Map<String, dynamic> json) =>
      ServerResponse(message: json['message'], success: json['success']);

  @override
  String toString() => '{ message: $message, success: $success }';
}
