import 'package:esp_smartconfig/esp_smartconfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/auth/auth_provider.dart';
import 'package:mobile/shared/widgets/label_button/label_button.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../shared/utils/mqtt/mqtt_client.dart';

class AddDevicePage extends ConsumerStatefulWidget {
  const AddDevicePage({super.key});

  @override
  ConsumerState<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends ConsumerState<AddDevicePage> {
  MQTTClientManager mqttClientManager = MQTTClientManager();
  final String pubTopic = "topico/do/visage";

  @override
  void initState() {
    setupMqttClient();
    setupUpdatesListener();
    //espTouch();
    super.initState();
  }

  Future<void> espTouch() async {
    final status = await Permission.location.status;

    if (status.isGranted) {
      final info = NetworkInfo();
      final provisioner = Provisioner.espTouchV2();
      final wifiName = await info.getWifiName(); // "FooNetwork"
      final wifiBSSID = await info.getWifiBSSID();

      print(wifiName);
      print(wifiBSSID);

      provisioner.listen((response) {
        print("Device ${response.bssidText} connected to WiFi!");
      });
      print(ref.read(authProvider).user!.id);
      try {
        await provisioner.start(ProvisioningRequest.fromStrings(
            ssid: wifiName ?? '',
            bssid: wifiBSSID ?? '',
            password: "98706993",
            encryptionKey: "2893701982730182",
            reservedData: ref.read(authProvider).user!.id));

        // If you are going to use this library in Flutter
        // this is good place to show some Dialog and wait for exit
        //
        // Or simply you can delay with Future.delayed function
        await Future.delayed(const Duration(seconds: 15));
      } catch (e) {
        print(e);
      }

      provisioner.stop();
    } else {
      Map<Permission, PermissionStatus> req =
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

  @override
  void dispose() {
    mqttClientManager.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: LabelButtonWidget(
        label: "Mandar",
        onPressed: () {},
      ),
    );
  }
}
