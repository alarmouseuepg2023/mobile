import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/modules/devices/devices_page.dart';
import 'package:mobile/modules/home/home_page.dart';
import 'package:mobile/modules/login/login_page.dart';
import 'package:mobile/modules/profile/profile_page.dart';
import 'package:mobile/modules/register/register_page.dart';
import 'package:mobile/modules/splash/splash_page.dart';
import 'package:overlay_support/overlay_support.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            primarySwatch: Colors.blue,
            textTheme: GoogleFonts.notoSansTextTheme()),
        initialRoute: "/splash",
        routes: {
          "/splash": (context) => const SplashPage(),
          "/home": (context) => const HomePage(),
          "/login": (context) => const LoginPage(),
          "/register": (context) => const RegisterPage(),
          "/devices": (context) => const DevicesPage(),
          "/profile": (context) => const ProfilePage(),
        },
      ),
    );
  }
}
