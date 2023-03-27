import 'package:flutter/material.dart';
import 'package:mobile/shared/models/Device/device_model.dart';
import 'package:mobile/shared/widgets/label_button/label_button.dart';

import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_text_styles.dart';

class DevicePage extends StatefulWidget {
  final Device device;
  const DevicePage({super.key, required this.device});

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  String _getDeviceOwnership(String role) =>
      role == 'DEVICE_OWNER' ? 'Proprietário' : 'Convidado';

  bool _ownerPermissions(String role) => role == 'DEVICE_OWNER' ? true : false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: Text(
          widget.device.nickname,
          style: TextStyles.register,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Ink(
                  child: InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(50)),
                      onTap: () {},
                      child: const Icon(Icons.power_settings_new,
                          color: AppColors.primary, size: 100)),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(TextSpan(children: [
                  TextSpan(text: "Estado: ", style: TextStyles.deviceStatusSub),
                  TextSpan(
                      text: widget.device.status,
                      style: TextStyles.deviceCardStatus)
                ])),
                Text(_getDeviceOwnership(widget.device.role),
                    style: TextStyles.deviceCardOwnership),
                const SizedBox(
                  height: 30,
                ),
                Ink(
                  child: InkWell(
                      onTap: () {},
                      child: Row(
                        children: [
                          const Icon(Icons.analytics,
                              size: 40, color: AppColors.primary),
                          const SizedBox(
                            width: 20,
                          ),
                          Text(
                            "Atividades",
                            style: TextStyles.deviceActivities,
                          )
                        ],
                      )),
                ),
                const SizedBox(
                  height: 10,
                ),
                _ownerPermissions(widget.device.role)
                    ? Ink(
                        child: InkWell(
                            onTap: () {},
                            child: Row(
                              children: [
                                const Icon(Icons.people,
                                    size: 40, color: AppColors.primary),
                                const SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  "Compartilhar dispositivo",
                                  style: TextStyles.deviceActivities,
                                )
                              ],
                            )),
                      )
                    : const SizedBox(),
                const SizedBox(
                  height: 10,
                ),
                Ink(
                  child: InkWell(
                      onTap: () {},
                      child: Row(
                        children: [
                          const Icon(Icons.wifi,
                              size: 40, color: AppColors.primary),
                          const SizedBox(
                            width: 20,
                          ),
                          Text(
                            "Alterar rede Wifi",
                            style: TextStyles.deviceActivities,
                          )
                        ],
                      )),
                ),
                const SizedBox(
                  height: 10,
                ),
                Ink(
                  child: InkWell(
                      onTap: () {},
                      child: Row(
                        children: [
                          const Icon(Icons.lock,
                              size: 40, color: AppColors.primary),
                          const SizedBox(
                            width: 20,
                          ),
                          Text(
                            "Alterar senha do alarme",
                            style: TextStyles.deviceActivities,
                          )
                        ],
                      )),
                ),
              ],
            ),
            Expanded(child: Container()),
            _ownerPermissions(widget.device.role)
                ? LabelButtonWidget(
                    label: "REMOVER DISPOSITIVO",
                    onPressed: () {},
                    reversed: true,
                  )
                : const SizedBox(),
            const SizedBox(
              height: 30,
            )
          ]),
        ),
      ),
    ));
  }
}
