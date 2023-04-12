import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/modules/add_device/add_device_page.dart';
import 'package:mobile/modules/change_password/change_password_page.dart';
import 'package:mobile/modules/device/device_page.dart';
import 'package:mobile/modules/devices/devices_page.dart';
import 'package:mobile/modules/events/events_page.dart';
import 'package:mobile/modules/forgot_password/forgot_password_page.dart';
import 'package:mobile/modules/guests/guests_page.dart';
import 'package:mobile/modules/home/home_page.dart';
import 'package:mobile/modules/invite/invite_page.dart';
import 'package:mobile/modules/login/login_page.dart';
import 'package:mobile/modules/notifications/notifications_page.dart';
import 'package:mobile/modules/profile/profile_page.dart';
import 'package:mobile/modules/register/register_page.dart';
import 'package:mobile/modules/reset_password/reset_password_page.dart';
import 'package:mobile/modules/splash/splash_page.dart';
import 'package:mobile/shared/models/Device/device_model.dart';
import 'package:mobile/shared/models/Notifications/notification_model.dart';
import 'package:mobile/shared/themes/app_colors.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
        "/device": (context) => DevicePage(
              device: ModalRoute.of(context)!.settings.arguments as Device,
            ),
        "/guests": (context) => GuestsPage(
              device: ModalRoute.of(context)!.settings.arguments as Device,
            ),
        "/events": (context) => EventsPage(
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
      },
    );
  }
}
