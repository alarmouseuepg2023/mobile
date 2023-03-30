import 'package:mobile/shared/models/Notifications/notifications_list_model.dart';

class NotificationsResponse {
  final String message;
  final bool success;
  final NotificationsList content;

  NotificationsResponse({
    required this.message,
    required this.success,
    required this.content,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) =>
      NotificationsResponse(
          content: NotificationsList.fromJson(json['content']),
          message: json['message'],
          success: json['success']);

  @override
  String toString() =>
      '{ message: $message, success: $success, content: $content }';
}
