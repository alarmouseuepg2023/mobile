import 'dart:async';

import 'package:esp_smartconfig/esp_smartconfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart' as location_lib;
import 'package:mobile/modules/add_device/add_device_controller.dart';
import 'package:mobile/providers/auth/auth_provider.dart';
import 'package:mobile/shared/utils/validators/input_validators.dart';
import 'package:mobile/shared/widgets/label_button/label_button.dart';
import 'package:mobile/shared/widgets/snackbar/snackbar_widget.dart';
import 'package:mobile/shared/widgets/text_input/text_input.dart';
import 'package:mobile/shared/widgets/toast/toast_widget.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_text_styles.dart';
import '../../shared/utils/mqtt/mqtt_client.dart';

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
  String wifiSsid = '';
  String wifiBssid = '';
  bool allStepsCompleted = false;
  int _counter = 30;
  Timer _timer = Timer(const Duration(seconds: 30), () {});
  bool _restartTimer = false;
  int _pageMode = 0;
  String qrCode = "";
  final _addDeviceController = AddDeviceController();

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

  Future<void> turnOnCamera() async {
    final camera = await Permission.camera.status;
    if (camera.isGranted && mounted) {
      openQRScanner(context);
    } else {
      await [Permission.camera].request();
    }
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
      await [Permission.location].request();
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

  void setSteps() {
    switch (_pageMode) {
      case 0:
        {
          if (_addDeviceController.validateDeviceForm() == true) {
            setState(() {
              _pageMode = 1;
            });
          }
          break;
        }
      case 1:
        {
          if (_addDeviceController.validateDeviceForm() == true) {
            setState(() {
              _pageMode = 2;
            });
          }
          espTouch();
          break;
        }
      case 2:
        {
          break;
        }
    }
  }

  Future<void> espTouch() async {
    final status = await Permission.location.status;

    if (status.isGranted) {
      final info = NetworkInfo();
      final provisioner = Provisioner.espTouchV2();
      final wifiBSSID = await info.getWifiBSSID();

      provisioner.listen((response) {
        print(response);
        setState(() {
          isEspConnected = true;
        });
      });

      try {
        await provisioner.start(ProvisioningRequest.fromStrings(
            ssid: wifiSsid,
            bssid: wifiBSSID ?? '',
            password: wifiPassword.text,
            encryptionKey: "2893701982730182",
            reservedData: ref.read(authProvider).user!.id));

        _startTimer();
        await Future.delayed(const Duration(seconds: 30));
      } catch (e) {
        const GlobalSnackBar(
            message: "Ocorreu um problema ao conectar-se ao dispositivo.");
      }

      provisioner.stop();
    } else {
      await [Permission.location].request();
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
      turnOnCamera();
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
    mqttClientManager.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_pageMode != 0) {
          setState(() {
            _pageMode -= 1;
          });
        } else {
          Navigator.pop(context);
        }
        return false;
      },
      child: SafeArea(
          child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          shadowColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.primary),
          title: Text(
            'Adicionar dispositivo',
            style: TextStyles.register,
          ),
          centerTitle: true,
          leading: _pageMode == 0
              ? null
              : InkWell(
                  onTap: () {
                    if (_pageMode == 1) {
                      _timer.cancel();
                      _counter = 30;
                    }
                    setState(() {
                      _pageMode -= 1;
                    });
                  },
                  child: const Icon(Icons.arrow_back),
                ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: _pageMode == 0
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
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
                          height: 30,
                        ),
                        Text.rich(TextSpan(children: [
                          TextSpan(
                              text: "Rede: ", style: TextStyles.inviteAGuest),
                          TextSpan(
                              text: wifiSsid,
                              style: TextStyles.inviteAGuestBold)
                        ])),
                        Form(
                          key: _addDeviceController.formKey,
                          child: TextInputWidget(
                              label: "Senha da rede",
                              passwordType: true,
                              controller: wifiPassword,
                              validator: validatePassword,
                              onChanged: (value) {
                                _addDeviceController.onChange(
                                    wifiPassword: value);
                              }),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        Text.rich(
                          TextSpan(children: [
                            TextSpan(
                                text: "Escaneie o ",
                                style: TextStyles.addDeviceIntro),
                            TextSpan(
                                text: "QRCODE ",
                                style: TextStyles.addDeviceIntroBold),
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(3))),
                                child: InkWell(
                                  onTap: () {
                                    openQRScanner(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                                BorderSide(
                                                    color: AppColors.primary))),
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
                                                  BorderSide(
                                                      color:
                                                          AppColors.primary))),
                                          child: Ink(
                                            child: InkWell(
                                              onTap: () {
                                                openQRScanner(context);
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.all(11.5),
                                                child: Icon(
                                                  Icons
                                                      .qr_code_scanner_outlined,
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
                        //Expanded(child: Container()),
                        LabelButtonWidget(
                            label: "COMEÇAR",
                            disabled: allStepsCompleted,
                            onPressed: () async {
                              if (_addDeviceController.validateDeviceForm() ==
                                  true) {
                                if (qrCode == "" && mounted) {
                                  GlobalToast.show(context,
                                      "É necessário escanear o QRCODE do dispostivo");
                                  return;
                                }

                                final status = await Permission.location.status;
                                if (status.isGranted) {
                                  final locationCheck =
                                      await getLocationStatus();
                                  if (!locationCheck && mounted) {
                                    GlobalToast.show(context,
                                        "É necessário ativar a localização para prosseguir");
                                    return;
                                  }
                                  setSteps();
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
                                    setSteps();
                                  }
                                }
                              }
                            }),
                        const SizedBox(
                          height: 35,
                        )
                      ],
                    )
                  : _pageMode == 2
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Aguarde enquanto tentamos a conexão com o dispositivo.",
                              style: TextStyles.inviteAGuestBold,
                              textAlign: TextAlign.justify,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              "$_counter",
                              style: TextStyles.counterTitle,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            _restartTimer
                                ? InkWell(
                                    onTap: () {
                                      setState(() {
                                        _restartTimer = false;
                                        _counter = 30;
                                      });
                                      espTouch();
                                    },
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
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
                                : const SizedBox()
                          ],
                        )
                      : Column(
                          children: [
                            Text.rich(
                              TextSpan(children: [
                                TextSpan(
                                    text: "Escaneie o ",
                                    style: TextStyles.addDeviceIntro),
                                TextSpan(
                                    text: "QRCODE ",
                                    style: TextStyles.addDeviceIntroBold),
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
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(3))),
                                    child: InkWell(
                                      onTap: () {
                                        openQRScanner(context);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.qr_code_scanner_outlined,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              "Código do dispositivo",
                                              style: TextStyles.scanQrCode,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : Column(
                                    children: [
                                      Text(
                                        "Código do dispositivo",
                                        style: TextStyles.inviteAGuest,
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            decoration: const BoxDecoration(
                                                border: Border.fromBorderSide(
                                                    BorderSide(
                                                        color: AppColors
                                                            .primary))),
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
                                                      BorderSide(
                                                          color: AppColors
                                                              .primary))),
                                              child: Ink(
                                                child: InkWell(
                                                  onTap: () {
                                                    openQRScanner(context);
                                                  },
                                                  child: const Padding(
                                                    padding:
                                                        EdgeInsets.all(11.5),
                                                    child: Icon(
                                                      Icons
                                                          .qr_code_scanner_outlined,
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
                        )),
        ),
      )),
    );
  }
}
