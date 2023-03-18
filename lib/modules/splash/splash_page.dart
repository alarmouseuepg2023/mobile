import 'package:flutter/material.dart';
import 'package:mobile/shared/themes/app_colors.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

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
