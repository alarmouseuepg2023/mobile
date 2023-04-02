import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:mobile/shared/themes/app_colors.dart';

class GlobalToast {
  final String message;

  const GlobalToast({required this.message});

  static show(
    BuildContext context,
    String message,
  ) {
    Flushbar(
      backgroundColor: AppColors.text,
      message: message,
      duration: const Duration(seconds: 3),
      onTap: (flushbar) {
        flushbar.dismiss();
      },
      animationDuration: const Duration(milliseconds: 500),
    ).show(context);
  }
}
