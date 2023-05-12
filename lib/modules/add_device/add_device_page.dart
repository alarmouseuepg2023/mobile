import 'dart:async';

import 'package:esp_smartconfig/esp_smartconfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart' as location_lib;
import 'package:mobile/providers/auth/auth_provider.dart';
import 'package:mobile/shared/widgets/label_button/label_button.dart';
import 'package:mobile/shared/widgets/snackbar/snackbar_widget.dart';
import 'package:mobile/shared/widgets/text_input/text_input.dart';
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
  final String pubTopic = "topico/do/visage";
  bool isEspConnected = false;
  bool locationServicesActivated = false;
  TextEditingController wifiPassword = TextEditingController();
  String wifiSsid = '';
  String wifiBssid = '';
  bool allStepsCompleted = false;
  int _counter = 30;
  late Timer _timer;
  int _pageMode = 0;
  String qrCode = "";

  @override
  void initState() {
    turnOnLocationServices();
    // setupMqttClient();
    // setupUpdatesListener();
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
      }
    });
  }

  Future<void> turnOnLocationServices() async {
    final status = await Permission.location.status;
    final camera = await Permission.camera.status;
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
      turnOnLocationServices();
    }

    if (camera.isGranted) {
    } else {
      await [Permission.camera].request();
      turnOnLocationServices();
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

  void seefuture() {
    setState(() {
      _pageMode = 2;
    });
    //_startTimer();
  }

  Future<void> espTouch() async {
    final status = await Permission.location.status;

    if (status.isGranted) {
      final info = NetworkInfo();
      final provisioner = Provisioner.espTouchV2();
      final wifiBSSID = await info.getWifiBSSID();

      provisioner.listen((response) {
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
    await mqttClientManager.connect().then((value) {
      mqttClientManager.subscribe(pubTopic);
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
    }
  }

  @override
  void dispose() {
    mqttClientManager.disconnect();
    super.dispose();
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
          'Adicionar dispositivo',
          style: TextStyles.register,
        ),
        centerTitle: true,
      ),
      body: Padding(
          padding: const EdgeInsets.all(20),
          child: _pageMode == 0
              ? Column(
                  children: [
                    Text(
                      "Certifique-se de que a localização está ativada para iniciar o processo de adição do dispositivo.",
                      style: TextStyles.inviteAGuestBold,
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Text.rich(TextSpan(children: [
                      TextSpan(text: "Rede: ", style: TextStyles.inviteAGuest),
                      TextSpan(
                          text: wifiSsid, style: TextStyles.inviteAGuestBold)
                    ])),
                    TextInputWidget(
                        label: "Senha da rede",
                        passwordType: true,
                        controller: wifiPassword,
                        onChanged: (value) {}),
                    Expanded(child: Container()),
                    LabelButtonWidget(
                        label: "COMEÇAR",
                        disabled: allStepsCompleted,
                        onPressed: () {
                          seefuture();
                        })
                  ],
                )
              : _pageMode == 1
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
                        _counter != 30
                            ? Text(
                                "$_counter",
                                style: TextStyles.titleBig,
                              )
                            : const SizedBox(),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Text(
                          "Preencha as informações do dispositivo:",
                          style: TextStyles.inviteAGuestBold,
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        qrCode == ""
                            ? Ink(
                                decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
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
                      ],
                    )),
    ));
  }
}
