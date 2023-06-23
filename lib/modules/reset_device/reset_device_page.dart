import 'dart:async';
import 'dart:convert';

import 'package:esp_smartconfig/esp_smartconfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart' as location_lib;
import 'package:mobile/modules/add_device/add_device_controller.dart';
import 'package:mobile/providers/auth/auth_provider.dart';
import 'package:mobile/providers/notifications/notifications_provider.dart';
import 'package:mobile/shared/utils/validators/input_validators.dart';
import 'package:mobile/shared/widgets/snackbar/snackbar_widget.dart';
import 'package:mobile/shared/widgets/text_input/text_input.dart';
import 'package:mobile/shared/widgets/toast/toast_widget.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../shared/models/Device/device_model.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_text_styles.dart';
import '../../providers/mqtt/mqtt_client.dart';
import '../../shared/widgets/label_button/label_button.dart';
import '../../shared/widgets/step_button/step_button_widget.dart';

class ResetDevicePage extends ConsumerStatefulWidget {
  final Device device;
  const ResetDevicePage({super.key, required this.device});

  @override
  ConsumerState<ResetDevicePage> createState() => _ResetDevicePageState();
}

class _ResetDevicePageState extends ConsumerState<ResetDevicePage> {
  late MQTTClientManager mqttManager;
  bool locationServicesActivated = false;
  TextEditingController wifiPassword = TextEditingController();
  String wifiSsid = '';
  String wifiBssid = '';
  int _counter = 60;
  Timer _timer = Timer(const Duration(seconds: 1), () {});
  bool _restartTimer = false;
  int _pageMode = 0;
  String qrCode = "";
  final _addDeviceController = AddDeviceController();
  int currentStep = 0;
  bool loading = false;
  bool espAnswered = false;
  bool checked = false;
  bool provisionStarted = false;
  final provisioner = Provisioner.espTouchV2();
  late String espResponseTopic;

  @override
  void initState() {
    mqttManager = ref.read(mqttProvider);
    espResponseTopic =
        '/alarmouse/mqtt/sm/${dotenv.env['MQTT_PUBLIC_HASH']}/notification/status/change';
    turnOnLocationServices();
    setupUpdatesListener();
    super.initState();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_counter > 0 && mounted) {
        setState(() {
          _counter--;
        });
      }
      if (_counter == 0 && mounted) {
        _timer.cancel();
        setState(() {
          _restartTimer = true;
        });
      }
    });
  }

  Future<void> turnOnLocationServices() async {
    final status = await Permission.location.status;
    if (status.isGranted) {
      location_lib.Location location = location_lib.Location();
      bool serviceEnabled;
      location_lib.PermissionStatus permissionGranted;

      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          setState(() {
            locationServicesActivated = false;
          });
        } else {
          getNetworkInfos();
          setState(() {
            locationServicesActivated = true;
          });
        }
      } else {
        getNetworkInfos();
        setState(() {
          locationServicesActivated = true;
        });
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == location_lib.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != location_lib.PermissionStatus.granted) {
          return;
        }
      }
    } else {
      await Permission.location.request();
    }
  }

  Future<void> getNetworkInfos() async {
    final info = NetworkInfo();
    final ssid = await info.getWifiName();
    final bssid = await info.getWifiBSSID();

    setState(() {
      wifiSsid = ssid ?? '';
      wifiBssid = bssid ?? '';
    });
  }

  Future<void> espTouch() async {
    final status = await Permission.location.status;

    if (status.isGranted) {
      final info = NetworkInfo();
      final wifiBSSID = await info.getWifiBSSID();

      // provisioner.listen((response) {
      //   // _timer.cancel();

      //   // if (provisioner.running) {
      //   //   provisioner.stop();
      //   // }
      //   // setState(() {
      //   //   espAnswered = true;
      //   //   _pageMode = 2;
      //   // });
      // });

      try {
        provisionStarted
            ? setState(() {
                provisionStarted = false;
              })
            : null;
        await provisioner.start(ProvisioningRequest.fromStrings(
            ssid: wifiSsid,
            bssid: wifiBSSID ?? '',
            password: wifiPassword.text,
            encryptionKey: qrCode,
            reservedData: ref.read(authProvider).user!.id));

        setState(() {
          provisionStarted = true;
        });
        _startTimer();

        await Future.delayed(const Duration(seconds: 59));
      } catch (e) {
        const GlobalSnackBar(
            message: "Ocorreu um problema ao conectar-se ao dispositivo.");
      }

      if (provisioner.running) {
        provisioner.stop();
      }
    } else {
      await Permission.location.request();
    }
  }

  void setupUpdatesListener() {
    mqttManager
        .getMessagesStream()!
        .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final message =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      final topic = c[0].topic;

      if (topic == espResponseTopic) {
        handleEspAnswered(message);
      }
    });
  }

  void handleEspAnswered(String message) {
    final decoded = jsonDecode(message);
    String macAddress = decoded['macAddress'];
    int status = decoded['status'];

    print("DEVICES_PAGE: $macAddress O STATUS: $status - MOUNTED: $mounted");
    if (widget.device.macAddress == macAddress && mounted) {
      _timer.cancel();

      if (provisioner.running) {
        provisioner.stop();
      }
      setState(() {
        _pageMode = 2;
        espAnswered = true;
      });
    }
  }

  Future<void> openQRScanner(BuildContext context) async {
    final camera = await Permission.camera.status;
    if (camera.isGranted) {
      final code = await FlutterBarcodeScanner.scanBarcode(
          "#FFFFFF", "Cancelar", false, ScanMode.QR);

      if (code != "-1") {
        RegExp regex = RegExp(r'^[0-9]{1,16}$');

        if (regex.hasMatch(code)) {
          setState(() {
            qrCode = code;
          });
        }
      }
    } else {
      await Permission.camera.request();
    }
  }

  Future<bool> getLocationStatus() async {
    final location = location_lib.Location();
    return await location.serviceEnabled();
  }

  @override
  void dispose() {
    wifiPassword.dispose();
    _timer.cancel();
    if (provisioner.running) {
      provisioner.stop();
    }
    super.dispose();
  }

  List<Step> configSteps() {
    return <Step>[
      Step(
        state: currentStep > 0 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 0,
        title: const Text("Rede WiFi"),
        content: Form(
          key: _addDeviceController.formKeys[0],
          child: Column(
            children: [
              Text("Insira a senha para a rede: ",
                  style: TextStyles.inviteAGuest),
              const SizedBox(
                height: 20,
              ),
              Text(wifiSsid, style: TextStyles.inviteAGuestBold),
              TextInputWidget(
                  label: "Senha da rede",
                  passwordType: true,
                  controller: wifiPassword,
                  validator: validatePassword,
                  onChanged: (value) {
                    _addDeviceController.onChange(wifiPassword: value);
                  }),
              const SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
      ),
      Step(
        state: currentStep > 1 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 1,
        title: const Text("QRCode do dispositivo"),
        content: Form(
          key: _addDeviceController.formKeys[1],
          child: Column(
            children: [
              Text.rich(
                TextSpan(children: [
                  TextSpan(
                      text: "Escaneie o ", style: TextStyles.addDeviceIntro),
                  TextSpan(
                      text: "QRCode ", style: TextStyles.addDeviceIntroBold),
                  TextSpan(
                      text: "presente no dispostivo:",
                      style: TextStyles.addDeviceIntro),
                ]),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 20,
              ),
              qrCode == ""
                  ? Ink(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border.fromBorderSide(
                              BorderSide(color: AppColors.primary)),
                          borderRadius: BorderRadius.all(Radius.circular(3))),
                      child: InkWell(
                        onTap: () {
                          openQRScanner(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.qr_code_scanner_outlined,
                                color: AppColors.primary,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Código do dispositivo",
                                style: TextStyles.inviteText,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Código do dispositivo",
                          style: TextStyles.inviteAGuest,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                  border: Border.fromBorderSide(
                                      BorderSide(color: AppColors.primary)),
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(5),
                                      topLeft: Radius.circular(5))),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  qrCode,
                                  style: TextStyles.pinInput,
                                ),
                              ),
                            ),
                            Container(
                                decoration: const BoxDecoration(
                                    border: Border.fromBorderSide(
                                        BorderSide(color: AppColors.primary)),
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(5),
                                        topRight: Radius.circular(5))),
                                child: Ink(
                                  child: InkWell(
                                    onTap: () {
                                      openQRScanner(context);
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(11.5),
                                      child: Icon(
                                        Icons.qr_code_scanner_outlined,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ],
                    ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
      Step(
        state: currentStep > 2 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 2,
        title: const Text("Conexão com o dispositivo"),
        content: Form(
          key: _addDeviceController.formKeys[2],
          child: Column(
            children: [
              _counter == 60 && !espAnswered
                  ? InkWell(
                      onTap: () {
                        setState(() {
                          _counter = 59;
                        });
                        espTouch();
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                            border: Border.fromBorderSide(
                                BorderSide(color: AppColors.primary)),
                            borderRadius: BorderRadius.all(Radius.circular(3))),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(
                              Icons.wifi_tethering,
                              color: AppColors.primary,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Iniciar busca",
                              style: TextStyles.inviteTextBold,
                            ),
                          ]),
                        ),
                      ),
                    )
                  : !espAnswered
                      ? Column(
                          children: [
                            Text(
                              "Aguarde enquanto tentamos a conexão com o dispositivo.",
                              style: TextStyles.inviteAGuestBold,
                              textAlign: TextAlign.justify,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            provisionStarted
                                ? Text(
                                    "$_counter",
                                    style: TextStyles.counterTitle,
                                  )
                                : const CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        )
                      : const SizedBox(),
              _restartTimer
                  ? InkWell(
                      onTap: () {
                        _timer.cancel();
                        if (provisioner.running) {
                          provisioner.stop();
                        }
                        setState(() {
                          _restartTimer = false;
                          _counter = 59;
                        });
                        espTouch();
                      },
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(
                          Icons.refresh,
                          color: AppColors.primary,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Tentar Novamente",
                          style: TextStyles.inviteTextBold,
                        )
                      ]),
                    )
                  : const SizedBox(),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (currentStep != 0 && _pageMode == 0) {
          setState(() {
            currentStep -= 1;
          });
        } else {
          if (provisioner.running) {
            provisioner.stop();
          }
          Navigator.pop(context);
        }
        return false;
      },
      child: SafeArea(
          child: Scaffold(
        appBar: _pageMode != 2
            ? AppBar(
                backgroundColor: Colors.white,
                shadowColor: Colors.white,
                elevation: 0,
                iconTheme: const IconThemeData(color: AppColors.primary),
                title: Text(
                  'Reconfigurar dispositivo',
                  style: TextStyles.register,
                ),
                centerTitle: true,
              )
            : null,
        body: _pageMode == 1
            ? SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      children: [
                        Stepper(
                          physics: const ClampingScrollPhysics(),
                          type: StepperType.vertical,
                          currentStep: currentStep,
                          onStepCancel: () {
                            if (currentStep != 0) {
                              if (currentStep == 2) {
                                _timer.cancel();

                                setState(() {
                                  _counter = 60;
                                  currentStep -= 1;
                                });
                                return;
                              }
                              setState(() {
                                currentStep -= 1;
                              });
                            }
                          },
                          onStepContinue: () async {
                            bool isConnectionStep = (currentStep == 2);
                            bool isQRCodeStep = (currentStep == 1);

                            if (isConnectionStep) {
                              if (!espAnswered) {
                                GlobalToast.show(context,
                                    "Aguarde pela busca do dispostivo");
                              } else {
                                _timer.cancel();

                                setState(() {
                                  _counter = 60;
                                  currentStep += 1;
                                });
                              }
                              return;
                            }

                            if (isQRCodeStep) {
                              if (qrCode == '') {
                                GlobalToast.show(context,
                                    "É necessário escanear o QRCode do dispositivo");
                                return;
                              }

                              final status = await Permission.location.status;
                              if (status.isGranted) {
                                final locationCheck = await getLocationStatus();
                                if (!locationCheck && mounted) {
                                  GlobalToast.show(context,
                                      "É necessário ativar a localização para prosseguir");
                                  return;
                                }
                              } else {
                                turnOnLocationServices();
                                final status = await Permission.location.status;
                                if (status.isGranted) {
                                  final locationCheck =
                                      await getLocationStatus();
                                  if (!locationCheck && mounted) {
                                    GlobalToast.show(context,
                                        "É necessário ativar a localização para prosseguir");
                                    return;
                                  }
                                }
                              }
                            }

                            setState(() {
                              if (_addDeviceController
                                  .formKeys[currentStep].currentState!
                                  .validate()) {
                                if (currentStep < configSteps().length - 1) {
                                  currentStep += 1;
                                }
                              }
                            });
                          },
                          onStepTapped: null,
                          steps: configSteps(),
                          controlsBuilder: (context, details) {
                            return currentStep == configSteps().length - 1
                                ? const SizedBox()
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      StepButtonWidget(
                                          loading: loading,
                                          disabled: loading,
                                          label: "PRÓXIMO",
                                          onPressed: details.onStepContinue!),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      StepButtonWidget(
                                          disabled: loading,
                                          label: "ANTERIOR",
                                          reversed: true,
                                          onPressed: details.onStepCancel!),
                                    ],
                                  );
                          },
                        ),
                      ],
                    )),
              )
            : _pageMode == 0
                ? Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(children: [
                                  TextSpan(
                                      text: "Certifique-se de que a ",
                                      style: TextStyles.addDeviceIntro),
                                  TextSpan(
                                      text: "localização ",
                                      style: TextStyles.addDeviceIntroBold),
                                  TextSpan(
                                      text:
                                          " está ativada para iniciar o processo de redefinição do dispositivo.",
                                      style: TextStyles.addDeviceIntro),
                                ]),
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              Text.rich(
                                TextSpan(children: [
                                  TextSpan(
                                      text:
                                          "Antes de continuar, pressione o botão de ",
                                      style: TextStyles.addDeviceIntro),
                                  TextSpan(
                                      text: "reset ",
                                      style: TextStyles.addDeviceIntroBold),
                                  TextSpan(
                                      text:
                                          " que se encontra na lateral do dispositivo por ",
                                      style: TextStyles.addDeviceIntro),
                                  TextSpan(
                                      text: "3 segundos.",
                                      style: TextStyles.addDeviceIntroBold),
                                ]),
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(
                                height: 50,
                              ),
                              Row(
                                children: [
                                  Checkbox(
                                      activeColor: AppColors.primary,
                                      value: checked,
                                      onChanged: (value) {
                                        setState(() {
                                          checked = value ?? false;
                                        });
                                      }),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      "Pressionei o botão de reset por 3 segundos",
                                      style: TextStyles.deviceCardStatus,
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 50,
                              ),
                              checked
                                  ? LabelButtonWidget(
                                      disabled: !checked,
                                      label: "COMEÇAR",
                                      onPressed: () async {
                                        final status =
                                            await Permission.location.status;
                                        if (status.isGranted) {
                                          final locationCheck =
                                              await getLocationStatus();
                                          if (!locationCheck && mounted) {
                                            GlobalToast.show(context,
                                                "É necessário ativar a localização para prosseguir");
                                            return;
                                          }
                                        } else {
                                          turnOnLocationServices();
                                          final status =
                                              await Permission.location.status;
                                          if (status.isGranted) {
                                            final locationCheck =
                                                await getLocationStatus();
                                            if (!locationCheck && mounted) {
                                              GlobalToast.show(context,
                                                  "É necessário ativar a localização para prosseguir");
                                              return;
                                            }
                                          }
                                        }

                                        if (await getLocationStatus()) {
                                          getNetworkInfos();
                                          setState(() {
                                            _pageMode = 1;
                                          });
                                        }
                                      })
                                  : const SizedBox()
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Dispositivo ${widget.device.nickname} reconfigurado com sucesso!",
                                style: TextStyles.inviteTextAnswer,
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "Retorne para a tela de dispositivos",
                                style: TextStyles.inviteTextAnswerGoBack,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(
                                height: 50,
                              ),
                              LabelButtonWidget(
                                  label: "RETORNAR",
                                  onPressed: () {
                                    ref
                                        .read(notificationsProvider)
                                        .setNotifications(0);
                                    Navigator.pushReplacementNamed(
                                        context, '/home');
                                  })
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      )),
    );
  }
}
