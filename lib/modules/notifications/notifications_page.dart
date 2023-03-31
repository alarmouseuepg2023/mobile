import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/modules/notifications/notifications_controller.dart';
import 'package:mobile/shared/models/Notifications/notification_model.dart';
import 'package:mobile/shared/widgets/notification_card/notification_card_widget.dart';

import '../../shared/models/Response/server_response_model.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/widgets/snackbar/snackbar_widget.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _notificationsController = NotificationsController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool loading = false;
  List<NotificationModel> notifications = [];
  int totalItems = 0;
  bool _hasMore = true;
  int _pageNumber = 0;
  final int _size = 10;
  final scrollController = ScrollController();
  final int _answerMode = 0;

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

  // void showBottomSheet(context, NotificationModel notification) {
  //   showModalBottomSheet(
  //       context: context,
  //       isScrollControlled: true,
  //       builder: (BuildContext bc) {
  //         return StatefulBuilder(
  //             builder: (BuildContext context, StateSetter bottomState) {
  //           return Padding(
  //               padding: EdgeInsets.only(
  //                   bottom: MediaQuery.of(context).viewInsets.bottom,
  //                   left: 20,
  //                   right: 20,
  //                   top: 20),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   SizedBox(
  //                     width: double.maxFinite,
  //                     child: Stack(
  //                       children: [
  //                         _answerMode != 0
  //                             ? Ink(
  //                                 child: InkWell(
  //                                   onTap: (() {
  //                                     bottomState(() {
  //                                       _answerMode = 0;
  //                                     });
  //                                   }),
  //                                   child: const Icon(
  //                                     Icons.arrow_back,
  //                                     color: AppColors.primary,
  //                                   ),
  //                                 ),
  //                               )
  //                             : const SizedBox(),
  //                         Align(
  //                           alignment: FractionalOffset.center,
  //                           child: _answerMode == 0
  //                               ? Text.rich(
  //                                   TextSpan(children: [
  //                                     TextSpan(
  //                                         text: 'Convite para ',
  //                                         style: TextStyles.inviteAGuest),
  //                                     TextSpan(
  //                                         text: notification.device.nickname,
  //                                         style: TextStyles.inviteAGuestBold)
  //                                   ]),
  //                                 )
  //                               : Text(
  //                                   getBottomTitle(_answerMode),
  //                                   style: TextStyles.inviteAGuest,
  //                                 ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   const SizedBox(height: 30),
  //                   _answerMode == 0
  //                       ? Column(
  //                           children: [
  //                             LabelButtonWidget(
  //                                 label: "ACEITAR",
  //                                 onLoading: loading,
  //                                 onPressed: () {
  //                                   _notificationsController.onChangeAccept(
  //                                       id: notification.id);
  //                                   bottomState(() {
  //                                     _answerMode = 1;
  //                                   });
  //                                 }),
  //                             const SizedBox(height: 20),
  //                             LabelButtonWidget(
  //                                 label: "REJEITAR",
  //                                 reversed: true,
  //                                 onLoading: loading,
  //                                 onPressed: () {
  //                                   _notificationsController.onChangeReject(
  //                                       id: notification.id);
  //                                   bottomState(() {
  //                                     _answerMode = 2;
  //                                   });
  //                                 }),
  //                             const SizedBox(
  //                               height: 30,
  //                             )
  //                           ],
  //                         )
  //                       : _answerMode == 1
  //                           ? Column(
  //                               children: [
  //                                 PinInputWidget(
  //                                     onChanged: (value) {
  //                                       _notificationsController.onChangeAccept(
  //                                           token: value);
  //                                     },
  //                                     validator: validatePin),
  //                                 const SizedBox(height: 20),
  //                                 PinInputWidget(
  //                                     onChanged: (value) {
  //                                       _notificationsController.onChangeAccept(
  //                                           token: value);
  //                                     },
  //                                     validator: validatePin),
  //                                 const SizedBox(height: 20),
  //                                 PinInputWidget(
  //                                     onChanged: (value) {
  //                                       _notificationsController.onChangeAccept(
  //                                           token: value);
  //                                     },
  //                                     validator: validatePin),
  //                                 const SizedBox(height: 20),
  //                                 // TextInputWidget(
  //                                 //     label: "Senha",
  //                                 //     passwordType: true,
  //                                 //     controller: _password,
  //                                 //     validator: validatePassword,
  //                                 //     onChanged: (value) {
  //                                 //       _notificationsController.onChangeAccept(
  //                                 //           password: value);
  //                                 //     }),
  //                                 // TextInputWidget(
  //                                 //     label: "Confirme a senha",
  //                                 //     passwordType: true,
  //                                 //     controller: _confirmPassword,
  //                                 //     validator: (value) =>
  //                                 //         validateConfirmPassword(
  //                                 //             value, _password.text),
  //                                 //     onChanged: (value) {
  //                                 //       _notificationsController.onChangeAccept(
  //                                 //           confirmPassword: value);
  //                                 //     }),
  //                                 const SizedBox(height: 20),
  //                                 LabelButtonWidget(
  //                                     label: "ACEITAR",
  //                                     onLoading: loading,
  //                                     onPressed: () {
  //                                       handleAnswerInvite(
  //                                           true, notification.id);
  //                                     }),
  //                                 const SizedBox(
  //                                   height: 30,
  //                                 )
  //                               ],
  //                             )
  //                           : _answerMode == 2
  //                               ? Column(
  //                                   children: [
  //                                     PinInputWidget(
  //                                         onChanged: (value) {
  //                                           _notificationsController
  //                                               .onChangeReject(token: value);
  //                                         },
  //                                         validator: validatePin),
  //                                     const SizedBox(height: 20),
  //                                     LabelButtonWidget(
  //                                         label: "REJEITAR",
  //                                         reversed: true,
  //                                         onLoading: loading,
  //                                         onPressed: () {
  //                                           handleAnswerInvite(
  //                                               false, notification.id);
  //                                         }),
  //                                     const SizedBox(
  //                                       height: 30,
  //                                     )
  //                                   ],
  //                                 )
  //                               : const SizedBox()
  //                 ],
  //               ));
  //         });
  //       }).whenComplete(() => {
  //         setState(() {
  //           _answerMode = 0;
  //         })
  //       });
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
                          Navigator.pushNamed(context, '/invite',
                              arguments: notification);
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
