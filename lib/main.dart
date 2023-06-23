import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/modules/add_device/add_device_page.dart';
import 'package:mobile/modules/change_password/change_password_page.dart';
import 'package:mobile/modules/confirm_account/confirm_account_page.dart';
import 'package:mobile/modules/delete_account/delete_account_page.dart';
import 'package:mobile/modules/device/device_page.dart';
import 'package:mobile/modules/devices/devices_page.dart';
import 'package:mobile/modules/events/events_page.dart';
import 'package:mobile/modules/forgot_device_password/forgot_device_password_page.dart';
import 'package:mobile/modules/forgot_password/forgot_password_page.dart';
import 'package:mobile/modules/guests/guests_page.dart';
import 'package:mobile/modules/home/home_page.dart';
import 'package:mobile/modules/invite/invite_page.dart';
import 'package:mobile/modules/login/login_page.dart';
import 'package:mobile/modules/notifications/notifications_page.dart';
import 'package:mobile/modules/profile/profile_page.dart';
import 'package:mobile/modules/register/register_page.dart';
import 'package:mobile/modules/reset_device/reset_device_page.dart';
import 'package:mobile/modules/reset_password/reset_password_page.dart';
import 'package:mobile/modules/splash/splash_page.dart';
import 'package:mobile/service/firebase_messaging.dart';
import 'package:mobile/shared/models/Device/device_model.dart';
import 'package:mobile/shared/models/Notifications/notification_model.dart';
import 'package:mobile/shared/themes/app_colors.dart';
import 'package:permission_handler/permission_handler.dart';

import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<dynamic> backgroundMessagingHandler(RemoteMessage message) async {
  print('BACKGROUND MESSAGE ${message.notification?.body}');
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final status = await Permission.notification.status;
  if (!status.isGranted) {
    await [Permission.notification].request();
  }
  try {
    final RemoteMessage? remoteMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (remoteMessage != null) {
      print("INITIAL MESSAGE: ${remoteMessage.toString()}");
    }
    await FirebaseMessagingService.initialize(flutterLocalNotificationsPlugin);
    FirebaseMessaging.onBackgroundMessage(backgroundMessagingHandler);
  } catch (e) {
    print("FIREBASE INITIALIZE: $e");
  }

  runApp(const ProviderScope(child: MyApp()));
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alarmouse',
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('pt', 'BR')],
      useInheritedMediaQuery: true,
      navigatorKey: navigatorKey,
      theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: AppColors.primary,
          colorScheme: Theme.of(context)
              .colorScheme
              .copyWith(primary: AppColors.primary),
          textTheme: GoogleFonts.notoSansTextTheme()),
      initialRoute: "/splash",
      routes: {
        "/splash": (context) => const SplashPage(),
        "/home": (context) => const HomePage(),
        "/login": (context) => const LoginPage(),
        "/register": (context) => const RegisterPage(),
        "/forgot_password": (context) => const ForgotPasswordPage(),
        "/reset_password": (context) => const ResetPasswordPage(),
        "/devices": (context) => const DevicesPage(),
        "/add_device": (context) => const AddDevicePage(),
        "/reset_device": (context) => ResetDevicePage(
              device: ModalRoute.of(context)!.settings.arguments as Device,
            ),
        "/device": (context) {
          final args = (ModalRoute.of(context)?.settings.arguments ??
              <String, dynamic>{}) as Map;

          return DevicePage(
            device: args['device'] as Device,
            devicePassword: args['devicePassword'] as String,
          );
        },
        "/guests": (context) => GuestsPage(
              device: ModalRoute.of(context)!.settings.arguments as Device,
            ),
        "/events": (context) => EventsPage(
              device: ModalRoute.of(context)!.settings.arguments as Device,
            ),
        "/forgot_device_password": (context) => ForgotDevicePasswordPage(
              device: ModalRoute.of(context)!.settings.arguments as Device,
            ),
        "/notifications": (context) => const NotificationsPage(),
        "/invite": (context) {
          final args = (ModalRoute.of(context)?.settings.arguments ??
              <String, dynamic>{}) as Map;

          return InvitePage(
            notification: args['notification'] as NotificationModel,
            notificationsCount: args['notificationsCount'] as int,
          );
        },
        "/profile": (context) => const ProfilePage(),
        "/change_password": (context) => const ChangePasswordPage(),
        "/delete_account": (context) => const DeleteAccountPage(),
        "/confirm_account": (context) => ConfirmAccountPage(
              email: ModalRoute.of(context)!.settings.arguments as String,
            ),
      },
    );
  }
}
