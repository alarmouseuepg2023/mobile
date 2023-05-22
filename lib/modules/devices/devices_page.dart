import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/modules/devices/devices_controller.dart';
import 'package:mobile/shared/models/Response/server_response_model.dart';
import 'package:mobile/shared/themes/app_colors.dart';
import 'package:mobile/shared/utils/device_status/device_status_map.dart';
import 'package:mobile/shared/widgets/device_card/device_card_widget.dart';
import 'package:mobile/shared/widgets/toast/toast_widget.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../../shared/models/Device/device_model.dart';
import '../../shared/utils/mqtt/mqtt_client.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  final _devicesController = DevicesController();
  bool loading = false;
  List<Device> devices = [];
  int totalItems = 0;
  bool _hasMore = true;
  int _pageNumber = 0;
  final int _size = 10;
  final scrollController = ScrollController();
  MQTTClientManager mqttClientManager = MQTTClientManager();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getDevices();
      scrollController.addListener(() {
        if (scrollController.position.maxScrollExtent ==
            scrollController.offset) {
          getDevices();
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> setupMqttClient() async {
    List<String> espTopicList = [];
    for (var element in devices) {
      String espResponseTopic =
          '/alarmouse/mqtt/sall/${dotenv.env['MQTT_PUBLIC_HASH']}/control/status/change/${element.macAddress}';

      espTopicList.add(espResponseTopic);
    }

    final espTriggerTopic =
        '/alarmouse/mqtt/eall/${dotenv.env['MQTT_PUBLIC_HASH']}/control/status/change';

    await mqttClientManager.connect().then((value) {
      for (var element in espTopicList) {
        mqttClientManager.subscribe(element);
      }
      mqttClientManager.subscribe(espTriggerTopic);
    });
  }

  void setupUpdatesListener() {
    mqttClientManager
        .getMessagesStream()!
        .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      final topicMac = c[0].topic.substring(c[0].topic.length - 17);

      print(topicMac);
      print(pt);

      if (pt.length > 1) {
        final decoded = jsonDecode(pt);
        if (devices
            .where((element) => element.macAddress == decoded['macAddress'])
            .isNotEmpty) {
          List<Device> deviceChanged = devices
              .where((element) => element.macAddress == decoded['macAddress'])
              .toList();

          Device newDevice = Device(
              id: deviceChanged[0].id,
              macAddress: deviceChanged[0].macAddress,
              nickname: deviceChanged[0].nickname,
              wifiSsid: deviceChanged[0].wifiSsid,
              role: deviceChanged[0].role,
              status: getDeviceStatusLabel(decoded['status']));

          List<Device> withoutOldDevice = devices
              .where((element) => element.macAddress != decoded['macAddress'])
              .toList();

          withoutOldDevice.add(newDevice);

          setState(() {
            devices = withoutOldDevice;
          });
          if (mounted) {
            GlobalToast.show(
                context, "O dispositivo ${newDevice.nickname} disparou!");
          }
        }
        return;
      } else {
        List<Device> deviceChanged =
            devices.where((element) => element.macAddress == topicMac).toList();

        Device newDevice = Device(
            id: deviceChanged[0].id,
            macAddress: deviceChanged[0].macAddress,
            nickname: deviceChanged[0].nickname,
            wifiSsid: deviceChanged[0].wifiSsid,
            role: deviceChanged[0].role,
            status: getDeviceStatusLabel(pt));

        List<Device> withoutOldDevice =
            devices.where((element) => element.macAddress != topicMac).toList();

        withoutOldDevice.add(newDevice);

        setState(() {
          devices = withoutOldDevice;
        });
      }
    });
  }

  Future<void> getDevices() async {
    if (!mounted || loading) return;
    try {
      setState(() {
        loading = true;
      });

      final res = await _devicesController.getDevices(_pageNumber, _size);
      if (!mounted) return;
      setState(() {
        devices.addAll(res.content.items);
        if (res.content.items.length < _size) {
          _hasMore = false;
        }
        totalItems = res.content.totalItems;
        _pageNumber++;
      });

      setupMqttClient();
      setupUpdatesListener();
    } catch (e) {
      if (e is DioError) {
        if (e.response != null && e.response!.statusCode! >= 500) {
          GlobalToast.show(context, "Ocorreu um erro ao consultar o servidor.");
          return;
        }
        ServerResponse response = ServerResponse.fromJson(e.response?.data);

        GlobalToast.show(
            context,
            response.message != ""
                ? response.message
                : "Ocorreu um erro ao recuperar os dispositivos.");
      } else {
        GlobalToast.show(
            context, "Ocorreu um erro ao recuperar os dispositivos.");
      }
    } finally {
      // ignore: control_flow_in_finally
      if (!mounted) return;
      setState(() {
        loading = false;
      });
    }
  }

  Future refresh() async {
    setState(() {
      loading = false;
      _hasMore = true;
      _pageNumber = 0;
      devices.clear();
    });

    getDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(children: [
        Expanded(
          flex: 1,
          child: RefreshIndicator(
            onRefresh: refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: scrollController,
              itemCount: devices.length + 1,
              itemBuilder: (context, index) {
                if (index < devices.length) {
                  final device = devices[index];
                  return Column(children: [
                    DeviceCardWidget(
                      device: device,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          "/device",
                          arguments: device,
                        ).then((_) {
                          if (mounted) {
                            refresh();
                          }
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    )
                  ]);
                } else {
                  return _hasMore
                      ? const Center(
                          child: SizedBox(
                            height: 30,
                            width: 30,
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : const Center();
                }
              },
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: FloatingActionButton(
            onPressed: loading
                ? null
                : () {
                    Navigator.pushNamed(context, "/add_device").then((_) {
                      if (mounted) {
                        refresh();
                      }
                    });
                  },
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
      ]),
    );
  }
}
