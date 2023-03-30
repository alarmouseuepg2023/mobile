import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/modules/notifications/notifications_controller.dart';
import 'package:mobile/shared/models/Notifications/notification_model.dart';
import 'package:mobile/shared/widgets/notification_card/notification_card_widget.dart';

import '../../shared/models/Response/server_response_model.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_text_styles.dart';
import '../../shared/widgets/label_button/label_button.dart';
import '../../shared/widgets/snackbar/snackbar_widget.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _notificationsController = NotificationsController();
  bool loading = false;
  List<NotificationModel> notifications = [];
  int totalItems = 0;
  bool _hasMore = true;
  int _pageNumber = 0;
  final int _size = 10;
  final scrollController = ScrollController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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

        GlobalSnackBar.show(
            context,
            response.message != ""
                ? response.message
                : "Ocorreu um erro ao recuperar as notificações.");
      } else {
        GlobalSnackBar.show(
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

  Future refresh() async {
    setState(() {
      loading = false;
      _hasMore = true;
      _pageNumber = 0;
      notifications.clear();
    });

    getNotifications();
  }

  void showBottomSheet(context, NotificationModel notification) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext bc) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter bottomState) {
            return Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 20,
                    right: 20,
                    top: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(
                            text: 'Convite para ',
                            style: TextStyles.inviteAGuest),
                        TextSpan(
                            text: notification.device.nickname,
                            style: TextStyles.inviteAGuestBold)
                      ]),
                    ),
                    const SizedBox(height: 30),
                    LabelButtonWidget(
                        label: "ACEITAR", onLoading: loading, onPressed: () {}),
                    const SizedBox(height: 20),
                    LabelButtonWidget(
                        label: "REJEITAR",
                        reversed: true,
                        onLoading: loading,
                        onPressed: () {}),
                    const SizedBox(
                      height: 30,
                    )
                  ],
                ));
          });
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
              itemCount: notifications.length + 1,
              itemBuilder: (context, index) {
                if (index < notifications.length) {
                  final notification = notifications[index];
                  return Column(children: [
                    NotificationCardWidget(
                        notification: notification,
                        onTap: () {
                          showBottomSheet(context, notification);
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
