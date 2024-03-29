import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/modules/device/device_controller.dart';
import 'package:mobile/shared/models/Device/device_model.dart';
import 'package:mobile/shared/utils/validators/input_validators.dart';
import 'package:mobile/shared/widgets/label_button/label_button.dart';
import 'package:mobile/shared/widgets/pin_input/pin_input_widget.dart';
import 'package:mobile/shared/widgets/toast/toast_widget.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../../shared/models/Response/server_response_model.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_text_styles.dart';
import '../../shared/utils/device_status/device_status_map.dart';
import '../../providers/mqtt/mqtt_client.dart';
import '../../shared/widgets/text_input/text_input.dart';

class DevicePage extends ConsumerStatefulWidget {
  final Device device;
  const DevicePage({super.key, required this.device});

  @override
  ConsumerState<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends ConsumerState<DevicePage> {
  final deviceController = DeviceController();
  bool loading = false;
  bool bottomload = false;
  bool waitingDeviceResponse = false;
  String _status = '0';
  String _nickname = "";
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  String _getDeviceOwnership(String role) =>
      role == 'DEVICE_OWNER' ? 'Proprietário' : 'Convidado';
  late MQTTClientManager mqttManager;

  bool _ownerPermissions(String role) => role == 'DEVICE_OWNER' ? true : false;

  @override
  void initState() {
    mqttManager = ref.read(mqttProvider);
    setupUpdatesListener();
    setState(() {
      waitingDeviceResponse =
          widget.device.status == "Aguardando confirmação" ? true : false;
      _status = widget.device.status;
      _nickname = widget.device.nickname;
    });
    super.initState();
  }

  void setupUpdatesListener() {
    mqttManager
        .getMessagesStream()!
        .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final message =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      final topic = c[0].topic;
      String espResponseTopic =
          '/alarmouse/mqtt/sm/${dotenv.env['MQTT_PUBLIC_HASH']}/notification/status/change';

      if (topic == espResponseTopic) {
        handleStatusChanged(message);
      }
    });
  }

  void handleStatusChanged(String message) {
    final decoded = jsonDecode(message);

    String macAddress = decoded['macAddress'];
    int status = decoded['status'];

    print("DEVICE_PAGE: $macAddress O STATUS: $status MOUNTED: $mounted");
    if (macAddress == widget.device.macAddress && mounted) {
      if (status != 4) {
        setState(() {
          waitingDeviceResponse = false;
          _status = getDeviceStatusLabel(status.toString());
        });

        return;
      }

      if (status == 4 && status.toString() != getDeviceStatusCode(_status)) {
        setState(() {
          _status = getDeviceStatusLabel(status.toString());
        });
      }
    }
  }

  @override
  void dispose() {
    _password.dispose();
    _confirmPassword.dispose();
    _nicknameController.dispose();
    super.dispose();
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
        Navigator.pop(context);

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
          waitingDeviceResponse = true;
          _status = "Aguardando confirmação";
        });
        Navigator.pop(context);
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

        Navigator.pop(context);
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

  Future<void> handleChangeNickname(StateSetter bottomState) async {
    try {
      setState(() {
        loading = true;
      });
      bottomState(() {});
      final res = await deviceController.changeNickname(widget.device.id);
      if (res != null) {
        if (!mounted) return;

        setState(() {
          _nickname = _nicknameController.text;
        });
        Navigator.pop(context);
        GlobalToast.show(context,
            res.message != "" ? res.message : "Nome alterado com sucesso!");
      }
    } catch (e) {
      if (e is DioError) {
        ServerResponse response = ServerResponse.fromJson(e.response?.data);
        GlobalToast.show(
            context,
            response.message != ""
                ? response.message
                : "Ocorreu um erro ao renomear o dispositivo. Tente novamente.");
      } else {
        GlobalToast.show(context,
            "Ocorreu um erro ao renomear o dispositivo. Tente novamente.");
      }
    } finally {
      setState(() {
        loading = false;
      });

      bottomState(() {});
    }
  }

  Future<void> handleWifiReset(StateSetter bottomState) async {
    try {
      setState(() {
        loading = true;
      });
      bottomState(() {});
      final res = await deviceController.wifiResetStarted(widget.device.id);
      if (res != null) {
        if (!mounted) return;

        setState(() {
          _status = res.content.status;
        });
        Navigator.pop(context);
        GlobalToast.show(
            context,
            res.message != ""
                ? res.message
                : "Dispositivo está em modo de redefinição!");
      }
    } catch (e) {
      if (e is DioError) {
        ServerResponse response = ServerResponse.fromJson(e.response?.data);
        GlobalToast.show(
            context,
            response.message != ""
                ? response.message
                : "Ocorreu um erro ao redefinir o dispositivo. Tente novamente.");
      } else {
        GlobalToast.show(context,
            "Ocorreu um erro ao redefinir o dispositivo. Tente novamente.");
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
          return WillPopScope(
            onWillPop: () async {
              if (loading) return false;
              return true;
            },
            child: StatefulBuilder(
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
                              onComplete: (value) {
                                deviceController.onChangeStatus(
                                    password: value);
                                handleChangeStatus(bottomState);
                              },
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
                      loading
                          ? const SizedBox(
                              height: 40,
                              width: 40,
                              child: CircularProgressIndicator(
                                  color: AppColors.primary),
                            )
                          : const SizedBox(),
                      const SizedBox(
                        height: 40,
                      ),
                    ],
                  ),
                );
              }
              if (feature == 'SHARE') {
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
                          "Insira um e-mail para compartilhar",
                          style: TextStyles.inviteAGuest,
                        ),
                        const SizedBox(height: 30),
                        Form(
                          key: deviceController.inviteFormKey,
                          child: TextInputWidget(
                              notAnimated: true,
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
                    ));
              }
              if (feature == 'NICKNAME') {
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
                          "Insira o novo nome",
                          style: TextStyles.inviteAGuest,
                        ),
                        const SizedBox(height: 30),
                        Form(
                          key: deviceController.nicknameFormKey,
                          child: TextInputWidget(
                              notAnimated: true,
                              label: "Nome",
                              controller: _nicknameController,
                              validator: validateName,
                              maxLength: 32,
                              onChanged: (value) {
                                deviceController.onChangeNickname(
                                    nickname: value);
                              }),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        LabelButtonWidget(
                            label: "ENVIAR",
                            onLoading: loading,
                            onPressed: () {
                              handleChangeNickname(bottomState);
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
                          "Insira a senha do dispostivo",
                          style: TextStyles.inviteAGuest,
                        ),
                        const SizedBox(height: 30),
                        Form(
                          key: deviceController.wifiFormKey,
                          child: Column(children: [
                            PinInputWidget(
                              autoFocus: true,
                              onChanged: (value) => deviceController
                                  .onChangeWifi(password: value),
                              validator: validatePin,
                            ),
                          ]),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        LabelButtonWidget(
                            label: "ENVIAR",
                            onLoading: loading,
                            onPressed: () {
                              handleWifiReset(bottomState);
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
            }),
          );
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

  bool _getDeviceTriggered() => _status == "Disparado" ? true : false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: _getDeviceTriggered() ? AppColors.warning : null,
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(
            color: _getDeviceTriggered() ? Colors.white : AppColors.primary),
        flexibleSpace: Container(
            decoration: BoxDecoration(
                color:
                    _getDeviceTriggered() ? AppColors.warning : Colors.white)),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: InkWell(
                  onTap: _ownerPermissions(widget.device.role)
                      ? () {
                          _nicknameController.text = _nickname;
                          deviceController.onChangeNickname(
                              nickname: _nickname);
                          showBottomSheet(context, 'NICKNAME');
                        }
                      : null,
                  child: Text(
                    _nickname,
                    style: _getDeviceTriggered()
                        ? TextStyles.registerWhite
                        : TextStyles.register,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: _getDeviceTriggered()
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Ink(
                        child: InkWell(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50)),
                            onTap: () {
                              showBottomSheet(context, 'STATUS');
                            },
                            child: const Icon(Icons.warning_outlined,
                                color: Colors.white, size: 100)),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Alarme Disparado!",
                        style: TextStyles.devicePageAlarmTriggeredTitle,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text.rich(
                        TextSpan(children: [
                          TextSpan(
                              text:
                                  "Toque no ícone acima para inserir sua senha e desbloquear o dispositivo.",
                              style: TextStyles.devicePageAlarmTriggeredHelp),
                        ]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text.rich(
                        TextSpan(children: [
                          TextSpan(
                              text:
                                  "Você pode conferir o evento do disparo na seção de ",
                              style: TextStyles.devicePageAlarmTriggeredHelp),
                          TextSpan(
                              text: "Eventos ",
                              style:
                                  TextStyles.devicePageAlarmTriggeredHelpBold),
                          TextSpan(
                              text: "assim que desbloquear o dispostivo.",
                              style: TextStyles.devicePageAlarmTriggeredHelp),
                        ]),
                        textAlign: TextAlign.center,
                      ),
                    ]),
              ),
            )
          : _status == 'Desconfigurado'
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: waitingDeviceResponse
                                ? const Center(
                                    child: SizedBox(
                                      height: 100,
                                      width: 100,
                                      child: Center(
                                        child: SizedBox(
                                          height: 70,
                                          width: 70,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 6,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.sync_problem_outlined,
                                    color: AppColors.primary, size: 100),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(TextSpan(children: [
                                TextSpan(
                                    text: "Estado: ",
                                    style: TextStyles.deviceStatusSub),
                                TextSpan(
                                    text: _status,
                                    style: TextStyles.deviceCardStatus)
                              ])),
                              Text.rich(TextSpan(children: [
                                TextSpan(
                                    text: "Rede WiFi: ",
                                    style: TextStyles.deviceStatusSub),
                                TextSpan(
                                    text: widget.device.wifiSsid,
                                    style: TextStyles.deviceCardStatus)
                              ])),
                              Text(_getDeviceOwnership(widget.device.role),
                                  style: TextStyles.deviceCardOwnership),
                              const SizedBox(
                                height: 30,
                              ),
                              _ownerPermissions(widget.device.role)
                                  ? Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Ink(
                                          child: InkWell(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                    context, "/reset_device",
                                                    arguments: widget.device);
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                        Icons
                                                            .settings_backup_restore,
                                                        size: 30,
                                                        color:
                                                            AppColors.primary),
                                                    const SizedBox(
                                                      width: 20,
                                                    ),
                                                    Text(
                                                      "Realizar nova configuração",
                                                      style: TextStyles
                                                          .deviceActivities,
                                                    )
                                                  ],
                                                ),
                                              )),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      "Solicite a redefinição do dispostivo ao proprietário",
                                      style: TextStyles.deviceActivities,
                                      textAlign: TextAlign.center,
                                    ),
                            ])
                      ]),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: waitingDeviceResponse
                                  ? const Center(
                                      child: SizedBox(
                                        height: 100,
                                        width: 100,
                                        child: Center(
                                          child: SizedBox(
                                            height: 70,
                                            width: 70,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 6,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Ink(
                                      child: InkWell(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(50)),
                                          onTap: () {
                                            showBottomSheet(context, 'STATUS');
                                          },
                                          child: _status == "Disparado"
                                              ? const Icon(
                                                  Icons.warning_outlined,
                                                  color: Colors.white,
                                                  size: 100)
                                              : Icon(Icons.power_settings_new,
                                                  color:
                                                      _status == 'Desbloqueado'
                                                          ? AppColors.textFaded
                                                          : AppColors.activated,
                                                  size: 100)),
                                    ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(TextSpan(children: [
                                TextSpan(
                                    text: "Estado: ",
                                    style: TextStyles.deviceStatusSub),
                                TextSpan(
                                    text: _status,
                                    style: TextStyles.deviceCardStatus)
                              ])),
                              Text.rich(TextSpan(children: [
                                TextSpan(
                                    text: "Rede WiFi: ",
                                    style: TextStyles.deviceStatusSub),
                                TextSpan(
                                    text: widget.device.wifiSsid,
                                    style: TextStyles.deviceCardStatus)
                              ])),
                              Text(_getDeviceOwnership(widget.device.role),
                                  style: TextStyles.deviceCardOwnership),
                              const SizedBox(
                                height: 30,
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Ink(
                                    child: InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, "/events",
                                              arguments: widget.device);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.description,
                                                  size: 30,
                                                  color: AppColors.primary),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              Text(
                                                "Eventos",
                                                style:
                                                    TextStyles.deviceActivities,
                                              )
                                            ],
                                          ),
                                        )),
                                  ),
                                ],
                              ),
                              _ownerPermissions(widget.device.role)
                                  ? Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Ink(
                                          child: InkWell(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                    context, "/guests",
                                                    arguments: widget.device);
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.people,
                                                        size: 30,
                                                        color:
                                                            AppColors.primary),
                                                    const SizedBox(
                                                      width: 20,
                                                    ),
                                                    Text(
                                                      "Convidados",
                                                      style: TextStyles
                                                          .deviceActivities,
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
                                                    size: 30,
                                                    color: AppColors.primary),
                                                const SizedBox(
                                                  width: 20,
                                                ),
                                                Text(
                                                  "Compartilhar dispositivo",
                                                  style: TextStyles
                                                      .deviceActivities,
                                                )
                                              ],
                                            ),
                                          )),
                                    )
                                  : const SizedBox(),
                              const SizedBox(
                                height: 10,
                              ),
                              _ownerPermissions(widget.device.role)
                                  ? Ink(
                                      child: InkWell(
                                          onTap: () {
                                            showBottomSheet(context, 'WIFI');
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.wifi,
                                                    size: 30,
                                                    color: AppColors.primary),
                                                const SizedBox(
                                                  width: 20,
                                                ),
                                                Text(
                                                  "Redefinir rede WiFi",
                                                  style: TextStyles
                                                      .deviceActivities,
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
                                      showBottomSheet(context, 'PASSWORD');
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.lock,
                                              size: 30,
                                              color: AppColors.primary),
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
                          const SizedBox(
                            height: 50,
                          ),
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
