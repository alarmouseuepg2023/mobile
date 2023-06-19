import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile/shared/themes/app_colors.dart';

class FirebaseMessagingService {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  FirebaseMessagingService() {
    configurePermissions();
    onMessage();
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      print(fcmToken);
    }).onError((err) {
      // Error getting token.
    });
  }

  Future<void> configurePermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    const android = AndroidInitializationSettings(
        '@drawable/ic_alarmouse_logo_invertido_fundo_transparente');
    const initializationSettings = InitializationSettings(android: android);
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

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
              color: AppColors.text,
              styleInformation: bigTextStyleInformation,
              priority: Priority.high,
              playSound: true,
              icon: '@mipmap/ic_alarmouse_logo_invertido_fundo_transparente');
      NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidNotificationDetails,
      );
      await flutterLocalNotificationsPlugin.show(0, message.notification?.title,
          message.notification?.body, platformChannelSpecifics,
          payload: message.data['title']);
    });
  }
}
