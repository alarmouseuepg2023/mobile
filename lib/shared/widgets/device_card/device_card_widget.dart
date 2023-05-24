import 'package:flutter/material.dart';
import 'package:mobile/shared/models/Device/device_model.dart';
import 'package:mobile/shared/themes/app_colors.dart';
import 'package:mobile/shared/themes/app_text_styles.dart';

class DeviceCardWidget extends StatefulWidget {
  final Device device;
  final VoidCallback onTap;
  const DeviceCardWidget(
      {super.key, required this.device, required this.onTap});

  @override
  State<DeviceCardWidget> createState() => _DeviceCardWidgetState();
}

class _DeviceCardWidgetState extends State<DeviceCardWidget> {
  String _getDeviceOwnership(String role) =>
      role == 'DEVICE_OWNER' ? 'Proprietário' : 'Convidado';

  bool _getDeviceTriggered() =>
      widget.device.status == "Disparado" ? true : false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Ink(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 0), // changes position of shadow
              ),
            ],
            color: _getDeviceTriggered() ? AppColors.warning : Colors.white,
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.device.nickname,
                      style: _getDeviceTriggered()
                          ? TextStyles.deviceCardNameWarning
                          : TextStyles.deviceCardName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: false,
                    ),
                    Text.rich(TextSpan(children: [
                      TextSpan(
                          text: "Estado: ",
                          style: _getDeviceTriggered()
                              ? TextStyles.deviceStatusSubWarning
                              : TextStyles.deviceStatusSub),
                      TextSpan(
                          text: widget.device.status,
                          style: _getDeviceTriggered()
                              ? TextStyles.deviceCardStatusWarning
                              : TextStyles.deviceCardStatus)
                    ])),
                    Text(_getDeviceOwnership(widget.device.role),
                        style: _getDeviceTriggered()
                            ? TextStyles.deviceCardOwnershipWarning
                            : TextStyles.deviceCardOwnership),
                  ],
                ),
              ),
              widget.device.status == "Desconfigurado"
                  ? const Icon(Icons.sync_problem_outlined,
                      size: 50, color: AppColors.primary)
                  : widget.device.status == "Aguardando confirmação"
                      ? const Icon(Icons.sync_outlined,
                          size: 50, color: AppColors.primary)
                      : _getDeviceTriggered()
                          ? const Icon(Icons.warning_outlined,
                              size: 50, color: Colors.white)
                          : const SizedBox()
            ],
          )),
    );
  }
}
