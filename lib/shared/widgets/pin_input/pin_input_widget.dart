import 'package:flutter/material.dart';
import 'package:mobile/shared/themes/app_colors.dart';
import 'package:mobile/shared/themes/app_text_styles.dart';
import 'package:pinput/pinput.dart';

class PinInputWidget extends StatelessWidget {
  final Function(String?) onChanged;
  final Function(String?)? onComplete;
  final String? Function(String?)? validator;
  final bool? autoFocus;
  final bool? forceError;
  final TextEditingController? controller;
  const PinInputWidget(
      {super.key,
      required this.onChanged,
      this.onComplete,
      required this.validator,
      this.controller,
      this.autoFocus,
      this.forceError});

  @override
  Widget build(BuildContext context) {
    return Pinput(
        validator: validator,
        length: 6,
        forceErrorState: forceError ?? false,
        onChanged: onChanged,
        autofocus: autoFocus ?? false,
        onCompleted: onComplete,
        controller: controller,
        keyboardType: TextInputType.number,
        defaultPinTheme: PinTheme(
            height: 45,
            width: 45,
            textStyle: TextStyles.pinInput,
            decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: AppColors.primary, width: 1)),
            )));
  }
}
