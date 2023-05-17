import 'package:flutter/material.dart';
import 'package:mobile/shared/themes/app_colors.dart';

class StepIndicatorWidget extends StatelessWidget {
  final double step;
  const StepIndicatorWidget({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: step,
      backgroundColor: Colors.white,
      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
    );
  }
}
