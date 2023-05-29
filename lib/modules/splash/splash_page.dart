import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/auth/auth_provider.dart';
import 'package:mobile/shared/themes/app_colors.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool user = false;

  @override
  void initState() {
    getStorageData();
    super.initState();
  }

  Future<void> getStorageData() async {
    final hasUser = await ref.read(authProvider).getUserData();
    setState(() {
      user = hasUser;
    });
    Future.delayed(const Duration(seconds: 2)).then((_) {
      Navigator.pushReplacementNamed(
        context,
        user ? '/home' : '/login',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.primary),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/ALARMOUSE-LOGO-FUNDO-TRANSPARENTE.png",
              height: 400,
            ),
            const CircularProgressIndicator(
              color: Colors.white,
            )
          ]),
    );
  }
}
