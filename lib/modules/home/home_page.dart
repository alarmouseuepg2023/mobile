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

import '../../shared/models/Response/server_response_model.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_text_styles.dart';
import '../../shared/utils/mqtt/mqtt_client.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _homeController = HomeController();
  final _notificationsController = NotificationsController();
  bool _notificationsPreLoad = true;
  MQTTClientManager mqttClientManager = MQTTClientManager();

  String displayUserName(String name) => name.split(" ")[0];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setupMqttClient();
      getNotifications();
    });
    super.initState();
  }

  Future<void> setupMqttClient() async {
    await mqttClientManager.connect().onError((error, stackTrace) {
      print(error);

      return 0;
    }).then((value) {
      if (value == 0) return;
      final userId = ref.read(authProvider).user!.id;
      mqttClientManager.subscribe(
          "/alarmouse/mqtt/sm/${dotenv.env['MQTT_PUBLIC_HASH']}/notification/invite/$userId");

      setupUpdatesListener();
    });
  }

  void setupUpdatesListener() {
    mqttClientManager
        .getMessagesStream()!
        .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print('<${c[0].topic}> is $pt\n');
    });
  }

  Future<void> getNotifications() async {
    try {
      final res = await _notificationsController.getNotifications(0, 10);

      ref.read(notificationsProvider).setNotifications(res.content.totalItems);
    } catch (e) {
      print(e);
      if (e is DioError) {
        print(e.response);
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
                    title: Text("Notificações", style: TextStyles.welcome),
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
                        // if (ref.read(homeProvider).loading) return;
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
                        // if (ref.read(homeProvider).loading) return;
                        _homeController.setPage(1);
                        setState(() {});
                      },
                      child: Stack(children: [
                        Icon(
                          Icons.notifications,
                          size: 30,
                          color: _homeController.currentPage == 1
                              ? AppColors.primary
                              : AppColors.text,
                        ),
                        ref.watch(notificationsProvider).notificationsCount != 0
                            ? Positioned(
                                right: 0,
                                child: Container(
                                  decoration: const BoxDecoration(
                                      color: AppColors.warning,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  height: 10,
                                  width: 10,
                                ))
                            : const SizedBox()
                      ]),
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
