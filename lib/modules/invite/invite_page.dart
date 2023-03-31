import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/modules/invite/invite_controller.dart';
import 'package:mobile/shared/models/Notifications/notification_model.dart';
import 'package:mobile/shared/utils/validators/input_validators.dart';
import 'package:mobile/shared/widgets/step_indicator/step_indicator_widget.dart';

import '../../shared/models/Response/server_response_model.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_text_styles.dart';
import '../../shared/widgets/label_button/label_button.dart';
import '../../shared/widgets/pin_input/pin_input_widget.dart';
import '../../shared/widgets/snackbar/snackbar_widget.dart';

class InvitePage extends StatefulWidget {
  final NotificationModel notification;
  const InvitePage({super.key, required this.notification});

  @override
  State<InvitePage> createState() => _InviteAcceptPageState();
}

class _InviteAcceptPageState extends State<InvitePage> {
  final _inviteController = InviteController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  int _answerMode = 0;
  double _stepLength = 1;
  double _currentStep = 0;
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

  Widget acceptStepDecider(int currentStep) {
    switch (currentStep) {
      case 1:
        {
          return Column(
            children: [
              Text("Insira o código recebido por e-mail: ",
                  style: TextStyles.inviteText),
              const SizedBox(
                height: 20,
              ),
              PinInputWidget(
                  onChanged: (value) {
                    _inviteController.onChangeAccept(token: value);
                  },
                  validator: validatePin),
              const SizedBox(
                height: 40,
              ),
              LabelButtonWidget(
                  label: "PRÓXIMO",
                  onPressed: () {
                    if (_inviteController.validateStepInput(true)) {
                      setState(() {
                        _currentStep += 1;
                      });
                    }
                  })
            ],
          );
        }
      case 2:
        {
          return Column(
            children: [
              Text("Insira uma senha para o dispositivo: ",
                  style: TextStyles.inviteText),
              const SizedBox(
                height: 20,
              ),
              PinInputWidget(
                  controller: _password,
                  onChanged: (value) {
                    _inviteController.onChangeAccept(password: value);
                  },
                  validator: validatePinPassword),
              const SizedBox(
                height: 40,
              ),
              LabelButtonWidget(
                  label: "PRÓXIMO",
                  onPressed: () {
                    if (_inviteController.validateStepInput(true)) {
                      setState(() {
                        _currentStep += 1;
                      });
                    }
                  })
            ],
          );
        }
      case 3:
        {
          return Column(
            children: [
              Text("Confirme a senha para o dispositivo: ",
                  style: TextStyles.inviteText),
              const SizedBox(
                height: 20,
              ),
              PinInputWidget(
                  onChanged: (value) {
                    _inviteController.onChangeAccept(confirmPassword: value);
                  },
                  controller: _confirmPassword,
                  validator: (value) =>
                      validateConfirmPin(value, _password.text)),
              const SizedBox(
                height: 40,
              ),
              LabelButtonWidget(
                  label: "CONCLUIR",
                  onPressed: () {
                    if (_inviteController.validateStepInput(true)) {
                      setState(() {
                        _currentStep += 1;
                      });
                    }
                  })
            ],
          );
        }
      default:
        return const SizedBox();
    }
  }

  Widget rejectStepDecider(int currentStep) {
    switch (currentStep) {
      case 1:
        {
          return Column(
            children: [
              Text("Insira o código recebido por e-mail: ",
                  style: TextStyles.inviteText),
              const SizedBox(
                height: 20,
              ),
              PinInputWidget(
                  onChanged: (value) {
                    _inviteController.onChangeReject(token: value);
                  },
                  validator: validatePin),
              const SizedBox(
                height: 40,
              ),
              LabelButtonWidget(
                  label: "PRÓXIMO",
                  onPressed: () {
                    setState(() {
                      _currentStep += 1;
                    });
                  })
            ],
          );
        }
      case 2:
        {
          return Column(
            children: [
              Text("Tem certeza que deseja recusar?",
                  style: TextStyles.inviteText),
              const SizedBox(
                height: 20,
              ),
              Text(
                "Será necessário solicitar um novo convite ao proprietário",
                style: TextStyles.inviteTextBold,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 40,
              ),
              LabelButtonWidget(
                  label: "CONCLUIR",
                  onPressed: () {
                    setState(() {
                      _currentStep += 1;
                    });
                  })
            ],
          );
        }
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _answerMode == 0
            ? AppBar(
                backgroundColor: Colors.white,
                shadowColor: Colors.white,
                elevation: 0,
                iconTheme: const IconThemeData(color: AppColors.primary),
                title: Text(
                  "Convite de dispositivo",
                  style: TextStyles.register,
                ),
                centerTitle: true,
              )
            : null,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _answerMode != 0
                          ? Ink(
                              child: InkWell(
                                onTap: (() {
                                  setState(() {
                                    if (_currentStep == 1) {
                                      _answerMode = 0;
                                    } else {
                                      _currentStep -= 1;
                                    }
                                  });
                                }),
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : const SizedBox(),
                      const SizedBox(
                        height: 20,
                      ),
                      _answerMode != 0
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: StepIndicatorWidget(
                                  step: _currentStep / _stepLength),
                            )
                          : const SizedBox(),
                      const SizedBox(
                        height: 30,
                      )
                    ],
                  ),
                ),
                _answerMode == 0
                    ? Column(children: [
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
                              TextSpan(
                                  text: " de ", style: TextStyles.inviteText),
                              TextSpan(
                                  text: widget.notification.inviter.name,
                                  style: TextStyles.inviteTextBold),
                              TextSpan(
                                  text: " em ", style: TextStyles.inviteText),
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
                                    _stepLength = 3;
                                    _currentStep = 1;
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
                                    _stepLength = 2;
                                    _currentStep = 1;
                                  });
                                }),
                            const SizedBox(
                              height: 30,
                            ),
                          ],
                        )
                      ])
                    : _answerMode == 1
                        ? Column(
                            children: [
                              Form(
                                  key: _inviteController.acceptFormKey,
                                  child:
                                      acceptStepDecider(_currentStep.toInt()))
                            ],
                          )
                        : Column(children: [
                            Form(
                                key: _inviteController.rejectFormKey,
                                child: rejectStepDecider(_currentStep.toInt()))
                          ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
