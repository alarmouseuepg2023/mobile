import 'package:mobile/shared/models/Guest/guest_list_model.dart';

class GuestListResponse {
  final String message;
  final bool success;
  final GuestList content;

  GuestListResponse({
    required this.message,
    required this.success,
    required this.content,
  });

  factory GuestListResponse.fromJson(Map<String, dynamic> json) =>
      GuestListResponse(
          content: GuestList.fromJson(json['content']),
          message: json['message'],
          success: json['success']);

  @override
  String toString() =>
      '{ message: $message, success: $success, content: $content }';
}
