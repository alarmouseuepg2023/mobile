import 'package:flutter/material.dart';

import '../../themes/app_colors.dart';
import '../../themes/app_text_styles.dart';

class TextInputWidget extends StatefulWidget {
  final String label;
  final IconData? icon;
  final bool? passwordType;
  final String? initalValue;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final void Function(String value) onChanged;
  final bool? loading;
  final int? maxLength;

  const TextInputWidget({
    Key? key,
    required this.label,
    this.icon,
    required this.onChanged,
    this.initalValue,
    this.validator,
    this.controller,
    this.passwordType,
    this.loading,
    this.maxLength,
  }) : super(key: key);

  @override
  State<TextInputWidget> createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget> {
  bool hiddenPassword = false;

  @override
  void initState() {
    setState(() {
      hiddenPassword = widget.passwordType == true ? true : false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void togglePasswordView() {
      setState(() {
        hiddenPassword = !hiddenPassword;
      });
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          TextFormField(
            controller: widget.controller,
            initialValue: widget.initalValue,
            validator: widget.validator,
            onChanged: widget.onChanged,
            obscureText: hiddenPassword,
            enableSuggestions: !hiddenPassword,
            maxLength: widget.maxLength,
            autocorrect: !hiddenPassword,
            style: TextStyles.input,
            decoration: InputDecoration(
              suffixIcon: widget.passwordType == true
                  ? InkWell(
                      onTap: togglePasswordView,
                      child: Icon(
                          hiddenPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.primary))
                  : widget.loading != null && widget.loading == true
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        )
                      : null,
              focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                  borderSide: BorderSide(color: AppColors.primary, width: 1)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              labelText: widget.label,
              labelStyle: TextStyles.input,
              prefixIcon: widget.icon != null
                  ? Icon(
                      widget.icon,
                      color: AppColors.primary,
                    )
                  : null,
              enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                  borderSide: BorderSide(color: AppColors.primary, width: 1)),
              errorBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                  borderSide: BorderSide(color: AppColors.primary, width: 1)),
              focusedErrorBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                  borderSide: BorderSide(color: AppColors.primary, width: 1)),
            ),
          )
        ],
      ),
    );
  }
}
