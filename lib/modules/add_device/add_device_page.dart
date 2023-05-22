import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:esp_smartconfig/esp_smartconfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart' as location_lib;
import 'package:mobile/modules/add_device/add_device_controller.dart';
import 'package:mobile/providers/auth/auth_provider.dart';
import 'package:mobile/shared/utils/validators/input_validators.dart';
import 'package:mobile/shared/widgets/snackbar/snackbar_widget.dart';
import 'package:mobile/shared/widgets/text_input/text_input.dart';
import 'package:mobile/shared/widgets/toast/toast_widget.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../shared/models/Response/server_response_model.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_text_styles.dart';
import '../../shared/utils/mqtt/mqtt_client.dart';
import '../../shared/widgets/label_button/label_button.dart';
import '../../shared/widgets/pin_input/pin_input_widget.dart';
import '../../shared/widgets/step_button/step_button_widget.dart';

class AddDevicePage extends ConsumerStatefulWidget {
  const AddDevicePage({super.key});

  @override
  ConsumerState<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends ConsumerState<AddDevicePage> {
  MQTTClientManager mqttClientManager = MQTTClientManager();
  bool isEspConnected = false;
  bool locationServicesActivated = false;
  TextEditingController wifiPassword = TextEditingController();
  TextEditingController ownerPassword = TextEditingController();
  String wifiSsid = '';
  String wifiBssid = '';
  bool allStepsCompleted = false;
  int _counter = 60;
  Timer _timer = Timer(const Duration(seconds: 60), () {});
  bool _restartTimer = false;
  int _pageMode = 0;
  String qrCode = "";
  final _addDeviceController = AddDeviceController();
  int currentStep = 0;
  bool loading = false;
  bool espAnswered = false;
  String macAddress = '';
  bool provisionStarted = false;
  final provisioner = Provisioner.espTouchV2();

  @override
  void initState() {
    turnOnLocationServices();
    setupMqttClient();
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

      provisioner.listen((response) {
        _timer.cancel();

        if (provisioner.running) {
          provisioner.stop();
        }
      });

      try {
        provisionStarted
            ? setState(() {
                provisionStarted = false;
              })
            : null;
        print("$wifiSsid - ${wifiPassword.text} - $qrCode $wifiBSSID");
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

        await Future.delayed(const Duration(seconds: 60));
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

  Future<void> setupMqttClient() async {
    final espResponseTopic =
        '/alarmouse/mqtt/em/${dotenv.env['MQTT_PUBLIC_HASH']}/device/configure/${ref.read(authProvider).user!.id}';
    await mqttClientManager.connect().then((value) {
      mqttClientManager.subscribe(espResponseTopic);
    });
  }

  void setupUpdatesListener() {
    mqttClientManager
        .getMessagesStream()!
        .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print('MQTTClient::Message received on topic: <${c[0].topic}> is $pt\n');
      final decoded = jsonDecode(pt);
      RegExp regex = RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$');
      if (regex.hasMatch(decoded['macAddress'])) {
        _timer.cancel();

        if (provisioner.running) {
          provisioner.stop();
        }
        setState(() {
          macAddress = decoded['macAddress'];
          espAnswered = true;
        });
      }
    });
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
      // if (mounted) {
      //   openQRScanner(context);
      // }
    }
  }

  Future<bool> getLocationStatus() async {
    final location = location_lib.Location();
    return await location.serviceEnabled();
  }

  @override
  void dispose() {
    wifiPassword.dispose();
    ownerPassword.dispose();
    _timer.cancel();
    mqttClientManager.disconnect();
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
              espAnswered
                  ? Column(
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          "Dispositivo encontrado:",
                          style: TextStyles.inviteText,
                        ),
                        Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: AppColors.primary)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.developer_board,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      macAddress,
                                      style: TextStyles.inviteTextBold,
                                    ),
                                  ]),
                            )),
                        const SizedBox(
                          height: 20,
                        )
                      ],
                    )
                  : const SizedBox(),
              _restartTimer
                  ? InkWell(
                      onTap: () {
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
      Step(
        state: currentStep > 3 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 3,
        title: const Text("Nome do dispositivo"),
        content: Form(
          key: _addDeviceController.formKeys[3],
          child: Column(
            children: [
              Text("Escolha um nome para o dispositivo: ",
                  style: TextStyles.inviteText),
              const SizedBox(
                height: 20,
              ),
              TextInputWidget(
                  label: "Nome",
                  maxLength: 32,
                  validator: validateName,
                  onChanged: (value) {
                    _addDeviceController.onChange(nickname: value);
                  }),
              const SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
      ),
      Step(
        state: currentStep > 4 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 4,
        title: const Text("Senha"),
        content: Form(
          key: _addDeviceController.formKeys[4],
          child: Column(
            children: [
              Text("Insira uma senha para o dispositivo: ",
                  style: TextStyles.inviteText),
              const SizedBox(
                height: 20,
              ),
              PinInputWidget(
                  forceError: true,
                  autoFocus: true,
                  controller: ownerPassword,
                  onChanged: (value) {
                    _addDeviceController.onChange(ownerPassword: value);
                  },
                  validator: validatePinPassword),
              const SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
      ),
      Step(
        state: currentStep > 5 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 5,
        title: const Text("Confirme a senha"),
        content: Form(
          key: _addDeviceController.formKeys[5],
          child: Column(
            children: [
              Text("Confirme a senha para o dispositivo: ",
                  style: TextStyles.inviteText),
              const SizedBox(
                height: 20,
              ),
              PinInputWidget(
                  forceError: true,
                  autoFocus: true,
                  onChanged: (value) {
                    _addDeviceController.onChange(confirmOwnerPassword: value);
                  },
                  validator: (value) =>
                      validateConfirmPin(value, ownerPassword.text)),
              const SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Future<void> handleCreateDevice() async {
    try {
      setState(() {
        loading = true;
      });
      final res = await _addDeviceController.createDevice(
          macAddress, wifiSsid.replaceAll('"', ''));
      if (res != null) {
        if (!mounted) return;

        setState(() {
          _pageMode = 2;
        });

        GlobalToast.show(
            context,
            res.message != ""
                ? res.message
                : "Dispositivo adicionado com sucesso!");
      }
    } catch (e) {
      if (e is DioError) {
        ServerResponse response = ServerResponse.fromJson(e.response?.data);
        GlobalToast.show(context, response.message);
      } else {
        GlobalToast.show(context,
            "Ocorreu um erro ao adicionar o dispositivo. Tente novamente.");
      }
    } finally {
      setState(() {
        loading = false;
      });
    }
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
                  'Adicionar dispositivo',
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
                            bool isLastStep =
                                (currentStep == configSteps().length - 1);
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

                            if (isLastStep) {
                              handleCreateDevice();
                              return;
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
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                StepButtonWidget(
                                    loading: loading,
                                    disabled: loading,
                                    label:
                                        currentStep == configSteps().length - 1
                                            ? "CONCLUIR"
                                            : "PRÓXIMO",
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
                                          " está ativada para iniciar o processo de adição do dispositivo.",
                                      style: TextStyles.addDeviceIntro),
                                ]),
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(
                                height: 50,
                              ),
                              LabelButtonWidget(
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
                                "Dispositivo adicionado com sucesso!",
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
                                    Navigator.pop(context);
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
