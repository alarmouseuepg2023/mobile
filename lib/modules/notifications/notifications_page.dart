import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/modules/notifications/notifications_controller.dart';
import 'package:mobile/shared/models/Notifications/notification_model.dart';
import 'package:mobile/shared/widgets/notification_card/notification_card_widget.dart';
import 'package:mobile/shared/widgets/toast/toast_widget.dart';

import '../../shared/models/Response/server_response_model.dart';
import '../../shared/themes/app_colors.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  final _notificationsController = NotificationsController();
  bool loading = false;
  List<NotificationModel> notifications = [];
  int totalItems = 0;
  bool _hasMore = true;
  int _pageNumber = 0;
  final int _size = 10;
  final scrollController = ScrollController();
  // MQTTClientManager mqttClientManager = MQTTClientManager();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getNotifications();
      // setupMqttClient();
      // setupUpdatesListener();
      scrollController.addListener(() {
        if (scrollController.position.maxScrollExtent ==
            scrollController.offset) {
          getNotifications();
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

  Future<void> getNotifications() async {
    if (!mounted || loading) return;
    try {
      setState(() {
        loading = true;
      });

      final res =
          await _notificationsController.getNotifications(_pageNumber, _size);
      if (!mounted) return;
      setState(() {
        notifications.addAll(res.content.items);
        if (res.content.items.length < _size) {
          _hasMore = false;
        }
        totalItems = res.content.totalItems;
        _pageNumber++;
      });
    } catch (e) {
      if (e is DioError) {
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
      // ignore: control_flow_in_finally
      if (!mounted) return;
      setState(() {
        loading = false;
      });
    }
  }

  String getBottomTitle(int mode) =>
      mode == 1 ? 'Aceitar convite' : 'Rejeitar convite';

  Future refresh() async {
    setState(() {
      loading = false;
      _hasMore = true;
      _pageNumber = 0;
      notifications.clear();
    });

    getNotifications();
  }

  // Future<void> setupMqttClient() async {
  //   await mqttClientManager.connect().then((value) {
  //     final userId = ref.read(authProvider).user!.id;
  //     mqttClientManager.subscribe(
  //         "/alarmouse/mqtt/sm/${dotenv.env['MQTT_PUBLIC_HASH']}/notification/invite/$userId");
  //   });
  // }

  // void setupUpdatesListener() {
  //   mqttClientManager
  //       .getMessagesStream()!
  //       .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
  //     final recMess = c![0].payload as MqttPublishMessage;
  //     final pt =
  //         MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
  //     print('<${c[0].topic}> is $pt\n');
  //   });
  // }

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
              itemCount: notifications.length + 1,
              itemBuilder: (context, index) {
                if (index < notifications.length) {
                  final notification = notifications[index];
                  return Column(children: [
                    NotificationCardWidget(
                        notification: notification,
                        onTap: () {
                          Navigator.pushNamed(context, '/invite', arguments: {
                            'notification': notification,
                            'notificationsCount': totalItems
                          });
                        }),
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
      ]),
    );
  }
}
