import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/modules/devices/devices_page.dart';
import 'package:mobile/modules/home/home_controller.dart';
import 'package:mobile/modules/notifications/notifications_controller.dart';
import 'package:mobile/modules/notifications/notifications_page.dart';
import 'package:mobile/modules/profile/profile_page.dart';
import 'package:mobile/providers/auth/auth_provider.dart';
import 'package:mobile/providers/notifications/notifications_provider.dart';
import 'package:mobile/shared/widgets/toast/toast_widget.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../../providers/mqtt/mqtt_client.dart';
import '../../shared/models/Response/server_response_model.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_text_styles.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver {
  final _homeController = HomeController();
  final _notificationsController = NotificationsController();
  bool _notificationsPreLoad = true;
  late String notificationsTopic;
  late String espResponseTopic;
  final StreamController<String> _streamController = StreamController<String>();
  Stream<String> get _stream => _streamController.stream;
  late MQTTClientManager mqttManager;
  AppLifecycleState? _notification;

  String displayUserName(String name) => name.split(" ")[0];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String userId = ref.read(authProvider).user!.id;
      espResponseTopic =
          '/alarmouse/mqtt/sm/${dotenv.env['MQTT_PUBLIC_HASH']}/notification/status/change';
      notificationsTopic =
          "/alarmouse/mqtt/sm/${dotenv.env['MQTT_PUBLIC_HASH']}/notification/invite/$userId";
      mqttManager = ref.read(mqttProvider);
      if (mqttManager.client == null) {
        mqttManager.initializeClient();
        setupMqttClient();
        setupUpdatesListener();
      }
      getNotifications();
    });
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    _notification = state;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _streamController.close();
    super.dispose();
  }

  Future<void> setupMqttClient() async {
    await mqttManager.connect().then((value) {
      mqttManager.subscribe(notificationsTopic);
      mqttManager.subscribe(espResponseTopic);
    });
  }

  void setupUpdatesListener() {
    if (mqttManager.client == null) return;
    String userId = ref.read(authProvider).user!.id;

    String notificationsTopic =
        "/alarmouse/mqtt/sm/${dotenv.env['MQTT_PUBLIC_HASH']}/notification/invite/$userId";
    mqttManager
        .getMessagesStream()!
        .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final topic = c[0].topic;
      final message =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      if (topic == notificationsTopic) {
        handleNotificationArrived(message);
        return;
      }
    });
  }

  void handleNotificationArrived(String message) {
    print(
        "HOME_PAGE: MENSAGEM: $message - MOUNTED: $mounted ${_notification?.index}");
    if (mounted && _homeController.currentPage != 1) {
      final currentNotificationsCount =
          ref.read(notificationsProvider).notificationsCount ?? 0;

      ref
          .read(notificationsProvider)
          .setNotifications(currentNotificationsCount + 1);
      _streamController.add('${currentNotificationsCount + 1}');
    }
  }

  Future<void> getNotifications() async {
    try {
      final res = await _notificationsController.getNotifications(0, 10);
      final currentNotificationsCount =
          ref.read(notificationsProvider).notificationsCount ?? 0;

      ref
          .read(notificationsProvider)
          .setNotifications(currentNotificationsCount + res.content.totalItems);
      _streamController
          .add('${currentNotificationsCount + res.content.totalItems}');
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
                : "Ocorreu um erro ao recuperar as notificações.");
      } else {
        GlobalToast.show(
            context, "Ocorreu um erro ao recuperar as notificações.");
      }
    } finally {
      setState(() {
        _notificationsPreLoad = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _homeController.currentPage == 0
            ? AppBar(
                title: Text(
                    "Bem-vindo, ${displayUserName(ref.read(authProvider).user?.name ?? "")}",
                    style: TextStyles.welcome),
                automaticallyImplyLeading: false,
                flexibleSpace: Container(
                    decoration: const BoxDecoration(color: AppColors.primary)),
              )
            : _homeController.currentPage == 1
                ? AppBar(
                    title: Text("Convites", style: TextStyles.welcome),
                    automaticallyImplyLeading: false,
                    flexibleSpace: Container(
                        decoration:
                            const BoxDecoration(color: AppColors.primary)),
                  )
                : null,
        body: _notificationsPreLoad
            ? Stack(
                children: [
                  Positioned(
                      child: Container(
                          color: Colors.grey.withOpacity(0.5),
                          child:
                              const Center(child: CircularProgressIndicator())))
                ],
              )
            : [
                DevicesPage(key: UniqueKey()),
                NotificationsPage(key: UniqueKey()),
                ProfilePage(
                  key: UniqueKey(),
                )
              ][_homeController.currentPage],
        bottomNavigationBar: !_notificationsPreLoad
            ? Container(
                height: 60,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                        top: BorderSide(width: 1, color: AppColors.primary))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Ink(
                        child: InkWell(
                      onTap: () {
                        _homeController.setPage(0);
                        setState(() {});
                      },
                      child: Icon(
                        Icons.sensors,
                        size: 30,
                        color: _homeController.currentPage == 0
                            ? AppColors.primary
                            : AppColors.text,
                      ),
                    )),
                    Ink(
                        child: InkWell(
                      onTap: () {
                        _homeController.setPage(1);
                        ref.read(notificationsProvider).setNotifications(0);
                        _streamController.add('0');
                        setState(() {});
                      },
                      child: SizedBox(
                        width: 100,
                        child: Center(
                          child: Stack(fit: StackFit.expand, children: [
                            Icon(
                              Icons.mark_as_unread,
                              size: 30,
                              color: _homeController.currentPage == 1
                                  ? AppColors.primary
                                  : AppColors.text,
                            ),
                            StreamBuilder<String>(
                              stream: _stream,
                              builder: (BuildContext context,
                                  AsyncSnapshot<String> snapshot) {
                                if (snapshot.hasData && snapshot.data != '0') {
                                  return Positioned(
                                      left: 55,
                                      top: 10,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            color: AppColors.warning,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        height: 20,
                                        width: 20,
                                        child: Center(
                                            child: Text(
                                                "${int.parse(snapshot.data ?? '0') > 9 ? '9+' : snapshot.data}",
                                                style: TextStyles
                                                    .whiteCounterLabel)),
                                      ));
                                } else {
                                  return const SizedBox();
                                }
                              },
                            ),
                          ]),
                        ),
                      ),
                    )),
                    Ink(
                        child: InkWell(
                      onTap: () {
                        // if (ref.read(homeProvider).loading) return;
                        _homeController.setPage(2);
                        setState(() {});
                      },
                      child: Icon(Icons.person,
                          size: 30,
                          color: _homeController.currentPage == 2
                              ? AppColors.primary
                              : AppColors.text),
                    )),
                  ],
                ))
            : null,
      ),
    );
  }
}
