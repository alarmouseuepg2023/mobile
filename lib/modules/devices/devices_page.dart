import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/modules/devices/devices_controller.dart';
import 'package:mobile/shared/models/Response/server_response_model.dart';
import 'package:mobile/shared/themes/app_colors.dart';
import 'package:mobile/shared/utils/device_status/device_status_map.dart';
import 'package:mobile/shared/utils/validators/input_validators.dart';
import 'package:mobile/shared/widgets/device_card/device_card_widget.dart';
import 'package:mobile/shared/widgets/toast/toast_widget.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../../shared/models/Device/device_model.dart';
import '../../providers/mqtt/mqtt_client.dart';
import '../../shared/themes/app_text_styles.dart';
import '../../shared/widgets/pin_input/pin_input_widget.dart';

class DevicesPage extends ConsumerStatefulWidget {
  const DevicesPage({super.key});

  @override
  ConsumerState<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends ConsumerState<DevicesPage>
    with WidgetsBindingObserver {
  final _devicesController = DevicesController();
  bool loading = false;
  bool bottomLoading = false;
  List<Device> devices = [];
  int totalItems = 0;
  bool _hasMore = true;
  int _pageNumber = 0;
  final int _size = 10;
  final scrollController = ScrollController();
  late MQTTClientManager mqttManager;
  List<String> pageTopics = [];
  late String espResponseTopic;
  TextEditingController devicePassword = TextEditingController();
  AppLifecycleState _notification = AppLifecycleState.resumed;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    getDevices();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      espResponseTopic =
          '/alarmouse/mqtt/sm/${dotenv.env['MQTT_PUBLIC_HASH']}/notification/status/change';

      mqttManager = ref.read(mqttProvider);

      if (mqttManager.client != null) {
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("DEVICES TRIGGER: $_notification");
    _notification = state;

    if (state == AppLifecycleState.resumed && mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void setupUpdatesListener() {
    print('LISTENER ${mqttManager.client?.connectionStatus?.state.index}');
    if (mqttManager.client != null &&
        mqttManager.client?.connectionStatus?.state.index == 3) {
      mqttManager
          .getMessagesStream()!
          .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
        final recMess = c![0].payload as MqttPublishMessage;
        final topic = c[0].topic;
        final message =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

        if (topic == espResponseTopic) {
          handleStatusChange(message);
          return;
        }
      });
    }
  }

  void handleStatusChange(String message) {
    final decoded = jsonDecode(message);
    String macAddress = decoded['macAddress'];
    int status = decoded['status'];

    print(
        "DEVICES_PAGE: $macAddress O STATUS: $status - MOUNTED: $mounted ${_notification.index}");
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

      if (_notification.index == 0) {
        setState(() {
          devices[devicePosition] = newDevice;
        });
      } else {
        devices[devicePosition] = newDevice;
      }
    }
  }

  Future<void> getDevices() async {
    print('GET DEVICES $_notification $mounted');
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

  Future<void> handleUnlockDevice(
      StateSetter bottomState, Device device) async {
    try {
      setState(() {
        bottomLoading = true;
      });
      bottomState(() {});

      final res = await _devicesController.unlockDevice(device.id);

      if (res != null) {
        if (!mounted) return;
        Navigator.pop(context);
        Navigator.pushNamed(context, "/device", arguments: {
          'device': device,
          'devicePassword': devicePassword.text
        }).then((_) {
          if (mounted) {
            _devicesController.onChangeUnlock(password: '');
            devicePassword.clear();
            refresh();
          }
        });
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
        bottomLoading = false;
      });

      bottomState(() {});
    }
  }

  void showBottomSheet(context, Device device) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext bc) {
          return WillPopScope(onWillPop: () async {
            if (bottomLoading) return false;
            devicePassword.clear();
            return true;
          }, child: StatefulBuilder(
              builder: (BuildContext context, StateSetter bottomState) {
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
                    "Insira a senha do dispositivo",
                    style: TextStyles.inviteAGuest,
                  ),
                  const SizedBox(height: 30),
                  Form(
                    key: _devicesController.unlockDeviceFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PinInputWidget(
                          controller: devicePassword,
                          autoFocus: true,
                          onComplete: (value) {
                            _devicesController.onChangeUnlock(password: value);
                            handleUnlockDevice(bottomState, device);
                          },
                          onChanged: (value) => _devicesController
                              .onChangeUnlock(password: value),
                          validator: validatePin,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  bottomLoading
                      ? const SizedBox(
                          height: 40,
                          width: 40,
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: Align(
                            alignment: FractionalOffset.bottomRight,
                            child: Ink(
                              child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.pushNamed(
                                            context, '/forgot_device_password',
                                            arguments: device)
                                        .then((_) {
                                      if (mounted) {
                                        _devicesController.onChangeUnlock(
                                            password: '');
                                        devicePassword.clear();
                                        refresh();
                                      }
                                    });
                                  },
                                  child: Text("Esqueceu a senha?",
                                      style: TextStyles.input)),
                            ),
                          ),
                        ),
                  const SizedBox(
                    height: 40,
                  ),
                ],
              ),
            );
          }));
        });
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
                        showBottomSheet(context, device);
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
