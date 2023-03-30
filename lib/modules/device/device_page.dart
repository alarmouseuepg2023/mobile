import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/modules/device/device_controller.dart';
import 'package:mobile/shared/models/Device/device_model.dart';
import 'package:mobile/shared/widgets/label_button/label_button.dart';

import '../../shared/models/Response/server_response_model.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_text_styles.dart';
import '../../shared/widgets/snackbar/snackbar_widget.dart';
import '../../shared/widgets/text_input/text_input.dart';

class DevicePage extends StatefulWidget {
  final Device device;
  const DevicePage({super.key, required this.device});

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  final deviceController = DeviceController();
  bool loading = false;
  bool bottomload = false;
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  String _getDeviceOwnership(String role) =>
      role == 'DEVICE_OWNER' ? 'Proprietário' : 'Convidado';

  bool _ownerPermissions(String role) => role == 'DEVICE_OWNER' ? true : false;

  Future<void> handleInvite(StateSetter bottomState) async {
    try {
      setState(() {
        loading = true;
      });
      bottomState(() {});
      final res = await deviceController.inviteGuest(widget.device.id);
      if (res != null) {
        if (!mounted) return;
        GlobalSnackBar.show(context,
            res.message != "" ? res.message : "Usuário criado com sucesso!");
      }
    } catch (e) {
      if (e is DioError) {
        ServerResponse response = ServerResponse.fromJson(e.response?.data);
        GlobalSnackBar.show(
            context,
            response.message != ""
                ? response.message
                : "Ocorreu um erro ao alterar a rede Wifi. Tente novamente.");
      } else {
        GlobalSnackBar.show(context,
            "Ocorreu um erro ao alterar a rede Wifi. Tente novamente.");
      }
    } finally {
      setState(() {
        loading = false;
      });

      bottomState(() {});
    }
  }

  Future<void> handleChangePassword(StateSetter bottomState) async {
    try {
      setState(() {
        loading = true;
      });
      bottomState(() {});
      final res = await deviceController.changePassword(widget.device.id);
      if (res != null) {
        if (!mounted) return;
        GlobalSnackBar.show(context,
            res.message != "" ? res.message : "Senha alterada com sucesso!");
      }
    } catch (e) {
      if (e is DioError) {
        ServerResponse response = ServerResponse.fromJson(e.response?.data);
        GlobalSnackBar.show(
            context,
            response.message != ""
                ? response.message
                : "Ocorreu um erro ao alterar a senha. Tente novamente.");
      } else {
        GlobalSnackBar.show(
            context, "Ocorreu um erro ao alterar a senha. Tente novamente.");
      }
    } finally {
      setState(() {
        loading = false;
      });

      bottomState(() {});
    }
  }

  void showBottomSheet(context, String feature) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext bc) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter bottomState) {
            if (feature == 'SHARE') {
              return Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                      left: 20,
                      right: 20,
                      top: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Insira um e-mail para compartilhar",
                        style: TextStyles.inviteAGuest,
                      ),
                      const SizedBox(height: 30),
                      Form(
                        key: deviceController.formKey,
                        child: TextInputWidget(
                            label: "E-mail",
                            validator: deviceController.validateEmail,
                            onChanged: (value) {
                              deviceController.onChange(email: value);
                            }),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      LabelButtonWidget(
                          label: "ENVIAR",
                          onLoading: loading,
                          onPressed: () {
                            handleInvite(bottomState);
                          }),
                      const SizedBox(
                        height: 30,
                      )
                    ],
                  ));
            }
            if (feature == 'WIFI') {
              return Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                      left: 20,
                      right: 20,
                      top: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Insira os dados da nova rede",
                        style: TextStyles.inviteAGuest,
                      ),
                      const SizedBox(height: 30),
                      Form(
                        key: deviceController.wifiFormKey,
                        child: Column(children: [
                          TextInputWidget(
                              label: "Nome da rede",
                              validator: deviceController.validateSsid,
                              onChanged: (value) {
                                deviceController.onChangeWifi(ssid: value);
                              }),
                          TextInputWidget(
                              label: "Senha",
                              passwordType: true,
                              validator: deviceController.validatePassword,
                              onChanged: (value) {
                                deviceController.onChangeWifi(password: value);
                              }),
                        ]),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      LabelButtonWidget(
                          label: "ALTERAR",
                          onLoading: loading,
                          onPressed: () {
                            deviceController.changeWifi(widget.device.id);
                          }),
                      const SizedBox(
                        height: 30,
                      )
                    ],
                  ));
            }
            if (feature == 'PASSWORD') {
              return Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                      left: 20,
                      right: 20,
                      top: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Complete os campos de senha",
                        style: TextStyles.inviteAGuest,
                      ),
                      const SizedBox(height: 30),
                      Form(
                        key: deviceController.passwordFormKey,
                        child: Column(children: [
                          TextInputWidget(
                              label: "Senha antiga",
                              validator: deviceController.validatePassword,
                              passwordType: true,
                              onChanged: (value) {
                                deviceController.onChangePassword(
                                    oldPassword: value);
                              }),
                          TextInputWidget(
                              label: "Nova senha",
                              validator: deviceController.validatePassword,
                              passwordType: true,
                              controller: _password,
                              onChanged: (value) {
                                deviceController.onChangePassword(
                                    password: value);
                              }),
                          TextInputWidget(
                              label: "Confirme a nova senha",
                              validator: (value) =>
                                  deviceController.validateConfirmPassword(
                                      value, _password.text),
                              passwordType: true,
                              controller: _confirmPassword,
                              onChanged: (value) {
                                deviceController.onChangePassword(
                                    confirmPassword: value);
                              }),
                        ]),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      LabelButtonWidget(
                          label: "ALTERAR",
                          onLoading: loading,
                          onPressed: () {
                            handleChangePassword(bottomState);
                          }),
                      const SizedBox(
                        height: 30,
                      )
                    ],
                  ));
            }
            return const SizedBox();
          });
        });
  }

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
                      onTap: () {
                        Navigator.pushNamed(context, "/events",
                            arguments: widget.device);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.description,
                                size: 30, color: AppColors.primary),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(
                              "Eventos",
                              style: TextStyles.deviceActivities,
                            )
                          ],
                        ),
                      )),
                ),
                const SizedBox(
                  height: 10,
                ),
                _ownerPermissions(widget.device.role)
                    ? Ink(
                        child: InkWell(
                            onTap: () {
                              showBottomSheet(context, 'SHARE');
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.people,
                                      size: 30, color: AppColors.primary),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    "Compartilhar dispositivo",
                                    style: TextStyles.deviceActivities,
                                  )
                                ],
                              ),
                            )),
                      )
                    : const SizedBox(),
                const SizedBox(
                  height: 10,
                ),
                Ink(
                  child: InkWell(
                      onTap: () {
                        showBottomSheet(context, 'WIFI');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.wifi,
                                size: 30, color: AppColors.primary),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(
                              "Alterar rede Wifi",
                              style: TextStyles.deviceActivities,
                            )
                          ],
                        ),
                      )),
                ),
                const SizedBox(
                  height: 10,
                ),
                Ink(
                  child: InkWell(
                      onTap: () {
                        showBottomSheet(context, 'PASSWORD');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.lock,
                                size: 30, color: AppColors.primary),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(
                              "Alterar senha do alarme",
                              style: TextStyles.deviceActivities,
                            )
                          ],
                        ),
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
