import 'package:flutter/material.dart';

import '../../themes/app_colors.dart';
import '../../themes/app_text_styles.dart';

class StepButtonWidget extends StatelessWidget {
  final bool? disabled;
  final bool? reversed;
  final String label;
  final VoidCallback onPressed;
  const StepButtonWidget(
      {super.key,
      required this.label,
      required this.onPressed,
      this.disabled,
      this.reversed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        border: reversed != null && reversed == true
            ? Border.all(color: AppColors.primary)
            : null,
        color: reversed != null && reversed == true
            ? Colors.white
            : AppColors.primary,
      ),
      width: 100,
      child: TextButton(
          onPressed: disabled == true ? null : onPressed,
          child: Text(
            label,
            style: (reversed == true
                ? TextStyles.primaryLabel
                : TextStyles.whiteLabel),
          )),
    );
  }
}
