import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/modules/invite/invite_controller.dart';
import 'package:mobile/shared/models/Notifications/notification_model.dart';

import '../../shared/models/Response/server_response_model.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_text_styles.dart';
import '../../shared/widgets/label_button/label_button.dart';
import '../../shared/widgets/snackbar/snackbar_widget.dart';

class InvitePage extends StatefulWidget {
  final NotificationModel notification;
  const InvitePage({super.key, required this.notification});

  @override
  State<InvitePage> createState() => _InviteAcceptPageState();
}

class _InviteAcceptPageState extends State<InvitePage> {
  final _inviteController = InviteController();
  int _answerMode = 0;
  bool loading = false;

  Future<void> handleAnswerInvite(bool answer, String notificationId) async {
    if (!mounted || loading) return;
    try {
      setState(() {
        loading = true;
      });

      if (answer) {
        await _inviteController.acceptInvite();
      } else {
        await _inviteController.rejectInvite();
      }
      // if (!mounted) return;
      // setState(() {
      //   notifications.removeWhere((item) => item.id == notificationId);
      //   totalItems = totalItems - 1;
      // });
    } catch (e) {
      if (e is DioError) {
        ServerResponse response = ServerResponse.fromJson(e.response?.data);

        GlobalSnackBar.show(
            context,
            response.message != ""
                ? response.message
                : "Ocorreu um erro ao responder ao convite.");
      } else {
        GlobalSnackBar.show(
            context, "Ocorreu um erro ao responder ao convite.");
      }
    } finally {
      // ignore: control_flow_in_finally
      if (!mounted) return;
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          shadowColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.primary),
          title: Text(
            "Convite de dispositivo",
            style: TextStyles.register,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              RichText(
                  textAlign: TextAlign.justify,
                  text: TextSpan(children: [
                    TextSpan(
                        text:
                            "Você foi convidado para ter acesso ao dispositivo: ",
                        style: TextStyles.inviteText),
                    TextSpan(
                        text: widget.notification.device.nickname,
                        style: TextStyles.inviteTextBold),
                    TextSpan(text: " de ", style: TextStyles.inviteText),
                    TextSpan(
                        text: widget.notification.inviter.name,
                        style: TextStyles.inviteTextBold),
                    TextSpan(text: " em ", style: TextStyles.inviteText),
                    TextSpan(
                        text: widget.notification.invitedAt,
                        style: TextStyles.inviteTextBold),
                  ])),
              const SizedBox(
                height: 50,
              ),
              Column(
                children: [
                  LabelButtonWidget(
                      label: "ACEITAR",
                      onLoading: loading,
                      onPressed: () {
                        _inviteController.onChangeAccept(
                            id: widget.notification.id);
                        setState(() {
                          _answerMode = 1;
                        });
                      }),
                  const SizedBox(height: 20),
                  LabelButtonWidget(
                      label: "REJEITAR",
                      reversed: true,
                      onLoading: loading,
                      onPressed: () {
                        _inviteController.onChangeReject(
                            id: widget.notification.id);
                        setState(() {
                          _answerMode = 2;
                        });
                      }),
                  const SizedBox(
                    height: 30,
                  )
                ],
              )
            ]),
          ),
        ),
      ),
    );
  }
}
