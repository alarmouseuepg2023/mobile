import 'package:flutter/material.dart';
import 'package:mobile/shared/models/Status/status_options_model.dart';
import 'package:mobile/shared/themes/app_colors.dart';

class DropdownMenuWidget extends StatelessWidget {
  final String label;
  final List<StatusOption> options;
  final void Function(String? value) onChanged;
  const DropdownMenuWidget(
      {super.key,
      required this.label,
      required this.options,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: SizedBox(
          width: double.maxFinite,
          height: 50,
          child: DropdownButtonFormField<String>(
              items:
                  options.map<DropdownMenuItem<String>>((StatusOption option) {
                return DropdownMenuItem<String>(
                  value: option.value,
                  child: Text(option.name),
                );
              }).toList(),
              isExpanded: true,
              decoration: InputDecoration(
                labelText: label,
                isCollapsed: true,
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              ),
              onChanged: onChanged)),
    );
  }
}
