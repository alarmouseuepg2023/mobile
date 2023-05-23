import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/modules/devices/devices_controller.dart';
import 'package:mobile/providers/auth/auth_provider.dart';
import 'package:mobile/providers/notifications/notifications_provider.dart';
import 'package:mobile/shared/models/Response/server_response_model.dart';
import 'package:mobile/shared/themes/app_colors.dart';
import 'package:mobile/shared/utils/device_status/device_status_map.dart';
import 'package:mobile/shared/widgets/device_card/device_card_widget.dart';
import 'package:mobile/shared/widgets/toast/toast_widget.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../../shared/models/Device/device_model.dart';
import '../../providers/mqtt/mqtt_client.dart';

class DevicesPage extends ConsumerStatefulWidget {
  const DevicesPage({super.key});

  @override
  ConsumerState<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends ConsumerState<DevicesPage> {
  final _devicesController = DevicesController();
  bool loading = false;
  List<Device> devices = [];
  int totalItems = 0;
  bool _hasMore = true;
  int _pageNumber = 0;
  final int _size = 10;
  final scrollController = ScrollController();
  late MQTTClientManager mqttManager;
  List<String> pageTopics = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String userId = ref.read(authProvider).user!.id;
      String espResponseTopic =
          '/alarmouse/mqtt/sm/${dotenv.env['MQTT_PUBLIC_HASH']}/notification/status/change';

      String notificationsTopic =
          "/alarmouse/mqtt/sm/${dotenv.env['MQTT_PUBLIC_HASH']}/notification/invite/$userId";
      pageTopics.addAll([espResponseTopic, notificationsTopic]);

      mqttManager = ref.read(mqttProvider);

      getDevices();
      if (mqttManager.client == null) {
        mqttManager.initializeClient();
        setupMqttClient();
        setupUpdatesListener();
      }
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
    await mqttManager.connect().then((value) {
      for (var element in pageTopics) {
        mqttManager.subscribe(element);
      }
    });
  }

  void setupUpdatesListener() {
    mqttManager
        .getMessagesStream()!
        .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final topic = c[0].topic;
      final message =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print(message);
      print(mounted);

      if (topic == pageTopics[0]) {
        handleStatusChange(message);
        return;
      }

      if (topic == pageTopics[1]) {
        handleNotificationArrived();
        return;
      }
    });
  }

  void handleNotificationArrived() {
    if (mounted) {
      print('notificas');
      final currentNotificationsCount =
          ref.read(notificationsProvider).notificationsCount ?? 0;

      ref
          .read(notificationsProvider)
          .setNotifications(currentNotificationsCount + 1);
    }
  }

  void handleStatusChange(String message) {
    final decoded = jsonDecode(message);
    String macAddress = decoded['macAddress'];
    int status = decoded['status'];

    if (devices
            .where((element) => element.macAddress == macAddress)
            .isNotEmpty &&
        mounted) {
      List<Device> deviceChanged =
          devices.where((element) => element.macAddress == macAddress).toList();
      int devicePosition =
          devices.indexWhere((element) => element.macAddress == macAddress);

      Device newDevice = Device(
          id: deviceChanged[0].id,
          macAddress: deviceChanged[0].macAddress,
          nickname: deviceChanged[0].nickname,
          wifiSsid: deviceChanged[0].wifiSsid,
          role: deviceChanged[0].role,
          status: getDeviceStatusLabel(status.toString()));

      setState(() {
        devices[devicePosition] = newDevice;
      });
      if (status == 3) {
        GlobalToast.show(
            context, "O dispositivo ${newDevice.nickname} disparou!");
      }
    }
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
