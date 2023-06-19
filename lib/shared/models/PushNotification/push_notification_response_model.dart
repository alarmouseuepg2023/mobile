import 'package:mobile/shared/models/PushNotification/push_notification_content_model.dart';

class PushNotificationResponse {
  final String message;
  final bool success;
  final PushNotificationContent content;

  PushNotificationResponse(
      {required this.message, required this.success, required this.content});

  factory PushNotificationResponse.fromJson(Map<String, dynamic> json) =>
      PushNotificationResponse(
          message: json['message'],
          success: json['success'],
          content: PushNotificationContent.fromJson(json['content']));

  @override
  String toString() =>
      '{ message: $message, success: $success, content: $content }';
}
