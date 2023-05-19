import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/modules/device/device_controller.dart';
import 'package:mobile/shared/models/Device/device_model.dart';
import 'package:mobile/shared/utils/validators/input_validators.dart';
import 'package:mobile/shared/widgets/label_button/label_button.dart';
import 'package:mobile/shared/widgets/pin_input/pin_input_widget.dart';
import 'package:mobile/shared/widgets/toast/toast_widget.dart';

import '../../shared/models/Response/server_response_model.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_text_styles.dart';
import '../../shared/utils/device_status/device_status_map.dart';
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
  String _status = '0';
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  String _getDeviceOwnership(String role) =>
      role == 'DEVICE_OWNER' ? 'Proprietário' : 'Convidado';

  bool _ownerPermissions(String role) => role == 'DEVICE_OWNER' ? true : false;

  @override
  void initState() {
    setState(() {
      _status = widget.device.status;
    });
    super.initState();
  }

  Future<void> handleInvite(StateSetter bottomState) async {
    try {
      setState(() {
        loading = true;
      });
      bottomState(() {});
      final res = await deviceController.inviteGuest(widget.device.id);
      if (res != null) {
        if (!mounted) return;

        GlobalToast.show(context,
            res.message != "" ? res.message : "Usuário convidado com sucesso!");
      }
    } catch (e) {
      if (e is DioError) {
        ServerResponse response = ServerResponse.fromJson(e.response?.data);
        GlobalToast.show(context, response.message);
      } else {
        GlobalToast.show(
            context, "Ocorreu um erro ao convidar o usuário. Tente novamente.");
      }
    } finally {
      setState(() {
        loading = false;
      });

      bottomState(() {});
    }
  }

  Future<void> handleChangeStatus(StateSetter bottomState) async {
    try {
      setState(() {
        loading = true;
      });
      bottomState(() {});

      final newStatus = getDeviceStatusCode(_status) == '2' ? '1' : '2';
      deviceController.onChangeStatus(status: newStatus);
      final res = await deviceController.changeStatus(widget.device.id);

      if (res != null) {
        if (!mounted) return;

        setState(() {
          _status = getDeviceStatusLabel(newStatus);
        });

        Navigator.pop(context);

        GlobalToast.show(context,
            res.message != "" ? res.message : "Estado alterado com sucesso!");
      }
    } catch (e) {
      if (e is DioError) {
        ServerResponse response = ServerResponse.fromJson(e.response?.data);
        GlobalToast.show(context, response.message);
      } else {
        GlobalToast.show(
            context, "Ocorreu um erro ao alterar o estado. Tente novamente.");
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
        GlobalToast.show(context,
            res.message != "" ? res.message : "Senha alterada com sucesso!");
      }
    } catch (e) {
      if (e is DioError) {
        ServerResponse response = ServerResponse.fromJson(e.response?.data);
        GlobalToast.show(
            context,
            response.message != ""
                ? response.message
                : "Ocorreu um erro ao alterar a senha. Tente novamente.");
      } else {
        GlobalToast.show(
            context, "Ocorreu um erro ao alterar a senha. Tente novamente.");
      }
    } finally {
      setState(() {
        loading = false;
      });

      bottomState(() {});
    }
  }

  Future<void> handleDeleteDevice() async {
    try {
      setState(() {
        loading = true;
      });
      final res = await deviceController.deleteDevice(widget.device.id);
      if (res != null) {
        if (!mounted) return;
        GlobalToast.show(
            context,
            res.message != ""
                ? res.message
                : "Dispostivo removido com sucesso!");

        Navigator.pushReplacementNamed(context, "/home");
      }
    } catch (e) {
      if (e is DioError) {
        ServerResponse response = ServerResponse.fromJson(e.response?.data);
        GlobalToast.show(
            context,
            response.message != ""
                ? response.message
                : "Ocorreu um erro ao remover o dispositivo. Tente novamente.");
      } else {
        GlobalToast.show(context,
            "Ocorreu um erro ao remover o dispositivo. Tente novamente.");
      }
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void showBottomSheet(context, String feature) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext bc) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter bottomState) {
            if (feature == 'STATUS') {
              return Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    top: 20,
                    left: 20,
                    right: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Mudar o estado do dispositivo",
                      style: TextStyles.inviteAGuest,
                    ),
                    const SizedBox(height: 30),
                    Form(
                      key: deviceController.statusFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PinInputWidget(
                            autoFocus: true,
                            onChanged: (value) => deviceController
                                .onChangeStatus(password: value),
                            validator: validatePin,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    LabelButtonWidget(
                        label: "ENVIAR",
                        onLoading: loading,
                        onPressed: () {
                          handleChangeStatus(bottomState);
                        }),
                    const SizedBox(
                      height: 30,
                    )
                  ],
                ),
              );
            }
            if (feature == 'SHARE') {
              return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: SizedBox(
                    height: 200,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Wrap(
                        children: [
                          Text(
                            "Insira um e-mail para compartilhar",
                            style: TextStyles.inviteAGuest,
                          ),
                          const SizedBox(height: 30),
                          Form(
                            key: deviceController.inviteFormKey,
                            child: TextInputWidget(
                                label: "E-mail",
                                validator: validateEmail,
                                onChanged: (value) {
                                  deviceController.onChangeInvite(email: value);
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
                      ),
                    ),
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
                              validator: validateSsid,
                              onChanged: (value) {
                                deviceController.onChangeWifi(ssid: value);
                              }),
                          TextInputWidget(
                              label: "Senha",
                              passwordType: true,
                              validator: validatePassword,
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
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Senha antiga",
                                style: TextStyles.inputFocus,
                                textAlign: TextAlign.start,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              PinInputWidget(
                                onChanged: (value) {
                                  deviceController.onChangePassword(
                                      oldPassword: value);
                                },
                                validator: validatePinPassword,
                              ),
                              Text(
                                "Nova senha",
                                style: TextStyles.inputFocus,
                                textAlign: TextAlign.start,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              PinInputWidget(
                                onChanged: (value) {
                                  deviceController.onChangePassword(
                                      password: value);
                                },
                                validator: validatePinPassword,
                                controller: _password,
                              ),
                              Text(
                                "Confirme a nova senha",
                                style: TextStyles.inputFocus,
                                textAlign: TextAlign.start,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              PinInputWidget(
                                onChanged: (value) {
                                  deviceController.onChangePassword(
                                      confirmPassword: value);
                                },
                                validator: (value) =>
                                    validateConfirmPin(value, _password.text),
                                controller: _confirmPassword,
                              ),
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

  void showAlertDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(
              child: Text(
                "Atenção!",
                style: TextStyles.addDeviceIntroBold,
              ),
            ),
            content: Text(
              "Tem certeza que deseja remover este dispositivo?",
              style: TextStyles.addDeviceIntro,
              textAlign: TextAlign.center,
            ),
            actions: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  handleDeleteDevice();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    "Continuar",
                    style: TextStyles.deleteDevice,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Cancelar",
                    style: TextStyles.cancelDialog,
                  ),
                ),
              ),
            ],
          );
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
                      onTap: () {
                        showBottomSheet(context, 'STATUS');
                      },
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
                  TextSpan(text: _status, style: TextStyles.deviceCardStatus)
                ])),
                Text(_getDeviceOwnership(widget.device.role),
                    style: TextStyles.deviceCardOwnership),
                const SizedBox(
                  height: 30,
                ),
                Column(
                  children: [
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
                  ],
                ),
                _ownerPermissions(widget.device.role)
                    ? Column(
                        children: [
                          Ink(
                            child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, "/guests",
                                      arguments: widget.device);
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
                                        "Convidados",
                                        style: TextStyles.deviceActivities,
                                      )
                                    ],
                                  ),
                                )),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      )
                    : const SizedBox(),
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
                                  const Icon(Icons.send_to_mobile,
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
                    onPressed: () {
                      showAlertDialog(context);
                    },
                    reversed: true,
                  )
                : const SizedBox(),
            const SizedBox(
              height: 60,
            )
          ]),
        ),
      ),
    ));
  }
}
