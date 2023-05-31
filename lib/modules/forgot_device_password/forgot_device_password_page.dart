import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/modules/forgot_device_password/forgot_device_password_controller.dart';
import 'package:mobile/shared/models/Device/device_model.dart';
import 'package:mobile/shared/utils/validators/input_validators.dart';

import '../../shared/models/Response/server_response_model.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_text_styles.dart';
import '../../shared/widgets/label_button/label_button.dart';
import '../../shared/widgets/pin_input/pin_input_widget.dart';
import '../../shared/widgets/toast/toast_widget.dart';

class ForgotDevicePasswordPage extends StatefulWidget {
  final Device device;
  const ForgotDevicePasswordPage({super.key, required this.device});

  @override
  State<ForgotDevicePasswordPage> createState() =>
      _ForgotDevicePasswordPageState();
}

class _ForgotDevicePasswordPageState extends State<ForgotDevicePasswordPage> {
  final _forgotDevicePasswordController = ForgotDevicePasswordController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  bool loading = false;
  bool alreadyHasPin = false;

  Future<void> handleForgotDevicePassword() async {
    try {
      setState(() {
        loading = true;
      });
      final res = await _forgotDevicePasswordController
          .forgotDevicePassword(widget.device.id);
      if (res != null) {
        if (!mounted) return;

        GlobalToast.show(context,
            res.message != "" ? res.message : "Código de redefinição enviado!");
        setState(() {
          alreadyHasPin = true;
        });
      }
    } catch (e) {
      if (e is DioError) {
        ServerResponse response = ServerResponse.fromJson(e.response?.data);
        GlobalToast.show(
            context,
            response.message != ""
                ? response.message
                : "Ocorreu um erro ao redefinir a senha do dispostivo. Tente novamente.");
      } else {
        GlobalToast.show(context,
            "Ocorreu um erro ao redefinir a senha do dispostivo. Tente novamente.");
      }
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> handleResetDevicePassword() async {
    try {
      setState(() {
        loading = true;
      });
      final res = await _forgotDevicePasswordController
          .resetDevicePassword(widget.device.id);
      if (res != null) {
        if (!mounted) return;
        Navigator.pop(context);
        GlobalToast.show(
            context,
            res.message != ""
                ? res.message
                : "Senha do dispositivo alterada com sucesso!");
      }
    } catch (e) {
      if (e is DioError) {
        ServerResponse response = ServerResponse.fromJson(e.response?.data);
        GlobalToast.show(
            context,
            response.message != ""
                ? response.message
                : "Ocorreu um erro ao alterar a senha do dispostivo. Tente novamente.");
      } else {
        GlobalToast.show(context,
            "Ocorreu um erro ao alterar a senha do dispostivo. Tente novamente.");
      }
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (alreadyHasPin || loading) {
          _password.clear();
          _confirmPassword.clear();
          setState(() {
            alreadyHasPin = false;
          });
          return false;
        }
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            shadowColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.primary),
            title: alreadyHasPin
                ? Text(
                    "Complete os campos de redefinição",
                    style: TextStyles.register,
                  )
                : Text(
                    "Esqueci a senha do dispositivo",
                    style: TextStyles.register,
                  ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: alreadyHasPin
                  ? Column(
                      children: [
                        Form(
                          key: _forgotDevicePasswordController.passwordFormKey,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 30),
                                Text(
                                  "Código",
                                  style: TextStyles.inputFocus,
                                  textAlign: TextAlign.start,
                                ),
                                PinInputWidget(
                                  onChanged: (value) {
                                    _forgotDevicePasswordController
                                        .onChangePassword(pin: value);
                                  },
                                  validator: validatePin,
                                  autoFocus: true,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "Nova senha",
                                  style: TextStyles.inputFocus,
                                  textAlign: TextAlign.start,
                                ),
                                PinInputWidget(
                                  onChanged: (value) {
                                    _forgotDevicePasswordController
                                        .onChangePassword(password: value);
                                  },
                                  validator: validatePinPassword,
                                  controller: _password,
                                  autoFocus: true,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "Confirme a nova senha",
                                  style: TextStyles.inputFocus,
                                  textAlign: TextAlign.start,
                                ),
                                PinInputWidget(
                                  onChanged: (value) {
                                    _forgotDevicePasswordController
                                        .onChangePassword(
                                            confirmPassword: value);
                                  },
                                  validator: (value) =>
                                      validateConfirmPin(value, _password.text),
                                  controller: _confirmPassword,
                                  autoFocus: true,
                                ),
                              ]),
                        ),
                        const SizedBox(
                          height: 60,
                        ),
                        LabelButtonWidget(
                            onLoading: loading,
                            label: 'ENVIAR',
                            onPressed: () {
                              handleResetDevicePassword();
                            }),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 30,
                        ),
                        Text.rich(
                          TextSpan(children: [
                            TextSpan(
                                text:
                                    "Esta operação causará o envio de um e-mail com um ",
                                style: TextStyles.addDeviceIntro),
                            TextSpan(
                                text: "código de 6 dígitos ",
                                style: TextStyles.addDeviceIntroBold),
                            TextSpan(
                                text:
                                    "para redefinição de senha deste dispositivo.",
                                style: TextStyles.addDeviceIntro),
                          ]),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Align(
                            alignment: FractionalOffset.bottomRight,
                            child: Ink(
                              child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      alreadyHasPin = true;
                                    });
                                  },
                                  child: Text("Já possuo um código",
                                      style: TextStyles.input)),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 60,
                        ),
                        LabelButtonWidget(
                            onLoading: loading,
                            label: 'ENVIAR',
                            onPressed: () {
                              handleForgotDevicePassword();
                            }),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
