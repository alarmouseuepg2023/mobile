// ignore_for_file: public_member_api_docs, sort_constructors_first
class PushNotificationContent {
  final String userId;
  final String fcmToken;
  final bool notificationEnabled;

  PushNotificationContent({
    required this.userId,
    required this.fcmToken,
    required this.notificationEnabled,
  });

  factory PushNotificationContent.fromJson(Map<String, dynamic> json) =>
      PushNotificationContent(
        userId: json['userId'],
        fcmToken: json['fcmToken'],
        notificationEnabled: json['notificationEnabled'],
      );
}
