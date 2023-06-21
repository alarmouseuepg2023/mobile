import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/modules/notifications/notifications_controller.dart';
import 'package:mobile/providers/auth/auth_provider.dart';
import 'package:mobile/shared/models/Notifications/notification_model.dart';
import 'package:mobile/shared/widgets/notification_card/notification_card_widget.dart';
import 'package:mobile/shared/widgets/toast/toast_widget.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../../providers/mqtt/mqtt_client.dart';
import '../../shared/models/Response/server_response_model.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_text_styles.dart';

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
  late MQTTClientManager mqttManager;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      mqttManager = ref.read(mqttProvider);

      if (mqttManager.client != null) {
        setupUpdatesListener();
      }
      getNotifications();
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

      final message = Uint8List.fromList(recMess.payload.message);
      final notification = utf8.decode(message);

      if (topic == notificationsTopic) {
        handleNotificationArrival(notification);
      }
    });
  }

  void handleNotificationArrival(String message) {
    print("NOTIFICATIONS_PAGE: MESSAGE: $message  MOUNTED: $mounted");
    final decoded = jsonDecode(message);
    NotificationModel notification = NotificationModel.fromJson(decoded);
    if (mounted) {
      if (notifications
          .where((element) => element.id == notification.id)
          .toList()
          .isEmpty) {
        setState(() {
          notifications.add(notification);
        });
      }
    }
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
                          }).then((_) {
                            if (mounted) {
                              refresh();
                            }
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
                      : Center(
                          child: Text("Não há convites para mostrar",
                              style: TextStyles.emptyList),
                        );
                }
              },
            ),
          ),
        ),
      ]),
    );
  }
}
