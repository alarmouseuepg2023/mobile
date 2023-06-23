import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile/shared/themes/app_colors.dart';

class FirebaseMessagingService {
  static Future<void> initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    const androidInitialize =
        AndroidInitializationSettings('@mipmap/ic_notification');
    const initializationSettings =
        InitializationSettings(android: androidInitialize);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((message) =>
        FirebaseMessagingService.onMessage(
            message, flutterLocalNotificationsPlugin));

    return;
  }

  static Future<void> onMessage(RemoteMessage message,
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      message.notification!.body.toString(),
      htmlFormatBigText: true,
      contentTitle: message.notification!.title.toString(),
      htmlFormatContent: true,
    );
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('Alarmouse', 'Alarmouse',
            importance: Importance.high,
            styleInformation: bigTextStyleInformation,
            priority: Priority.high,
            playSound: true,
            color: AppColors.textFaded,
            icon: '@drawable/ic_notification');
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(0, message.notification?.title,
        message.notification?.body, platformChannelSpecifics,
        payload: message.data['title']);
  }
}
