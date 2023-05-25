import 'package:flutter/material.dart';

import '../../themes/app_colors.dart';
import '../../themes/app_text_styles.dart';

class DatePickerWidget extends StatefulWidget {
  final String label;
  final String? initalValue;
  final String? Function(String?)? validator;
  final TextEditingController controller;
  final void Function(String value) onChanged;

  const DatePickerWidget({
    Key? key,
    required this.label,
    required this.onChanged,
    this.initalValue,
    this.validator,
    required this.controller,
  }) : super(key: key);

  @override
  State<DatePickerWidget> createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<DatePickerWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          TextFormField(
            controller: widget.controller,
            initialValue: widget.initalValue,
            validator: widget.validator,
            onChanged: widget.onChanged,
            readOnly: true,
            style: TextStyles.input,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                locale: const Locale('pt', 'BR'),
                context: context,
                initialDate: DateTime.now(), //get today's date
                firstDate: DateTime(2022),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                String isoDate = pickedDate.toIso8601String().split("T")[0];
                String formattedDate = isoDate.split('-').reversed.join('/');

                widget.controller.text = formattedDate;
                widget.onChanged(isoDate);
              }
            },
            decoration: InputDecoration(
              focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                  borderSide: BorderSide(color: AppColors.primary, width: 1)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              labelText: widget.label,
              labelStyle: TextStyles.input,
              prefixIcon: const Icon(Icons.date_range),
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
