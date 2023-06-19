import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile/service/index.dart';
import 'package:mobile/shared/themes/app_colors.dart';

import '../shared/models/PushNotification/push_notification_response_model.dart';

class FirebaseMessagingService {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  FirebaseMessagingService() {
    configurePermissions();
    onMessage();
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      print("ON REFRESH ->>>> $fcmToken");
      sendToken(fcmToken);
    }).onError((err) {
      // Error getting token.
    });
  }

  Future<PushNotificationResponse?> sendToken(String token) async {
    final dio = DioApi().dio;
    final formData = {'token': token};

    final response = await dio.patch('pushNotifications',
        data: formData, options: Options());
    PushNotificationResponse data =
        PushNotificationResponse.fromJson(response.data);
    return data;
  }

  Future<void> configurePermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // const android = AndroidInitializationSettings(
    //     '@mipmap/ic_notification');
    // const initializationSettings = InitializationSettings(android: android);
    // flutterLocalNotificationsPlugin.initialize(
    //   initializationSettings,
    // );

    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      badge: true,
      sound: true,
      alert: true,
    );
  }

  void onMessage() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
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
    });
  }
}
