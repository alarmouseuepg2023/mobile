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
  // FirebaseMessagingService() {
  //   configurePermissions();
  //   onMessage();
  //   FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
  //     print("ON REFRESH ->>>> $fcmToken");
  //     sendToken(fcmToken);
  //   }).onError((err) {
  //     // Error getting token.
  //   });
  // }

  // Future<PushNotificationResponse?> sendToken(String token) async {
  //   final dio = DioApi().dio;
  //   final formData = {'token': token};

  //   final response = await dio.patch('pushNotifications',
  //       data: formData, options: Options());
  //   PushNotificationResponse data =
  //       PushNotificationResponse.fromJson(response.data);
  //   return data;
  // }

  // Future<void> configurePermissions() async {
  //   FirebaseMessaging messaging = FirebaseMessaging.instance;

  //   await messaging.requestPermission(
  //     alert: true,
  //     announcement: false,
  //     badge: true,
  //     carPlay: false,
  //     criticalAlert: false,
  //     provisional: false,
  //     sound: true,
  //   );

  //   await FirebaseMessaging.instance
  //       .setForegroundNotificationPresentationOptions(
  //     badge: true,
  //     sound: true,
  //     alert: true,
  //   );
  // }

}
