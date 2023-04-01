import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/modules/invite/invite_controller.dart';
import 'package:mobile/shared/models/Notifications/notification_model.dart';
import 'package:mobile/shared/utils/validators/input_validators.dart';
import 'package:mobile/shared/widgets/step_button/step_button_widget.dart';

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
  bool loading = false;
  int currentStep = 0;

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

  List<Step> acceptSteps() {
    return <Step>[
      Step(
        state: currentStep > 0 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 0,
        title: const Text("Código"),
        content: Column(
          children: [
            Text("Insira o código recebido por e-mail: ",
                style: TextStyles.inviteText),
            const SizedBox(
              height: 20,
            ),
            PinInputWidget(
                autoFocus: true,
                onChanged: (value) {
                  _inviteController.onChangeAccept(token: value);
                },
                validator: validatePin),
            const SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
      Step(
        state: currentStep > 1 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 1,
        title: const Text("Senha"),
        content: Column(
          children: [
            Text("Insira uma senha para o dispositivo: ",
                style: TextStyles.inviteText),
            const SizedBox(
              height: 20,
            ),
            PinInputWidget(
                autoFocus: true,
                controller: _password,
                onChanged: (value) {
                  _inviteController.onChangeAccept(password: value);
                },
                validator: validatePinPassword),
            const SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
      Step(
        state: currentStep > 2 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 2,
        title: const Text("Confirmação"),
        content: Column(
          children: [
            Text("Confirme a senha para o dispositivo: ",
                style: TextStyles.inviteText),
            const SizedBox(
              height: 20,
            ),
            PinInputWidget(
                autoFocus: true,
                onChanged: (value) {
                  _inviteController.onChangeAccept(confirmPassword: value);
                },
                controller: _confirmPassword,
                validator: (value) =>
                    validateConfirmPin(value, _password.text)),
            const SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
    ];
  }

  List<Step> rejectSteps() {
    return <Step>[
      Step(
        state: currentStep > 0 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 0,
        title: const Text("Código"),
        content: Column(
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
          ],
        ),
      ),
      Step(
        state: currentStep > 1 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 1,
        title: const Text("Confirmação"),
        content: Column(
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
          ],
        ),
      ),
    ];
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _answerMode != 0
                ? Padding(
                    padding: const EdgeInsets.only(
                        top: 20, left: 20, right: 20, bottom: 10),
                    child: Ink(
                      child: InkWell(
                        onTap: (() {
                          setState(() {
                            currentStep = 0;
                            _answerMode = 0;
                          });
                        }),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
            _answerMode == 0
                ? Padding(
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
                          ),
                        ],
                      )
                    ]),
                  )
                : _answerMode == 1
                    ? Stepper(
                        type: StepperType.vertical,
                        currentStep: currentStep,
                        onStepCancel: () => currentStep == 0
                            ? null
                            : setState(() {
                                currentStep -= 1;
                              }),
                        onStepContinue: () {
                          bool isLastStep =
                              (currentStep == acceptSteps().length - 1);
                          if (isLastStep) {
                            //Do something with this information
                          } else {
                            setState(() {
                              currentStep += 1;
                            });
                          }
                        },
                        onStepTapped: (step) => setState(() {
                          currentStep = step;
                        }),
                        steps: acceptSteps(),
                        controlsBuilder: (context, details) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              StepButtonWidget(
                                  label: "PRÓXIMO",
                                  onPressed: details.onStepContinue!),
                              const SizedBox(
                                width: 10,
                              ),
                              StepButtonWidget(
                                  label: "ANTERIOR",
                                  reversed: true,
                                  onPressed: details.onStepCancel!),
                            ],
                          );
                        },
                      )
                    : Stepper(
                        type: StepperType.vertical,
                        currentStep: currentStep,
                        onStepCancel: () => currentStep == 0
                            ? null
                            : setState(() {
                                currentStep -= 1;
                              }),
                        onStepContinue: () {
                          bool isLastStep =
                              (currentStep == rejectSteps().length - 1);
                          if (isLastStep) {
                            //Do something with this information
                          } else {
                            setState(() {
                              currentStep += 1;
                            });
                          }
                        },
                        onStepTapped: (step) => setState(() {
                          currentStep = step;
                        }),
                        steps: rejectSteps(),
                        controlsBuilder: (context, details) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              StepButtonWidget(
                                  label: "PRÓXIMO",
                                  onPressed: details.onStepContinue!),
                              const SizedBox(
                                width: 10,
                              ),
                              StepButtonWidget(
                                  label: "ANTERIOR",
                                  reversed: true,
                                  onPressed: details.onStepCancel!),
                            ],
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}
