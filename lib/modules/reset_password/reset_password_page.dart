import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:mobile/modules/reset_password/reset_password_controller.dart';
import 'package:mobile/shared/widgets/pin_input/pin_input_widget.dart';

import '../../shared/models/Response/server_response_model.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_text_styles.dart';
import '../../shared/widgets/label_button/label_button.dart';
import '../../shared/widgets/snackbar/snackbar_widget.dart';
import '../../shared/widgets/text_input/text_input.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  bool loading = false;
  final _resetPasswordController = ResetPasswordContorller();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final TextEditingController _pin = TextEditingController();

  Future<void> handleSignUp() async {
    try {
      setState(() {
        loading = true;
      });

      final res = await _resetPasswordController.createResetPassword();

      if (res != null) {
        _password.clear();
        _confirmPassword.clear();
        _pin.clear();
        if (!mounted) return;
        GlobalSnackBar.show(context,
            res.message != "" ? res.message : "Senha redefinida com sucesso!");
      }
    } catch (e) {
      print(e);
      if (e is DioError) {
        ServerResponse response = ServerResponse.fromJson(e.response?.data);
        GlobalSnackBar.show(
            context,
            response.message != ""
                ? response.message
                : "Ocorreu um erro ao entrar. Tente novamente.");
      } else {
        GlobalSnackBar.show(
            context, "Ocorreu um erro ao entrar. Tente novamente.");
      }
    } finally {
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
            "Redefinir a senha",
            style: TextStyles.register,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _resetPasswordController.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  PinInputWidget(
                    validator: _resetPasswordController.validatePin,
                    controller: _pin,
                    onChanged: (value) {
                      _resetPasswordController.onChange(pin: value);
                    },
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  TextInputWidget(
                    label: "E-mail",
                    onChanged: (value) {
                      _resetPasswordController.onChange(email: value);
                    },
                    validator: (value) => EmailValidator.validate(value ?? '')
                        ? null
                        : "Insira um e-mail válido",
                  ),
                  TextInputWidget(
                      label: "Senha",
                      passwordType: true,
                      onChanged: (value) {
                        _resetPasswordController.onChange(password: value);
                      },
                      controller: _password,
                      validator: _resetPasswordController.validatePassword),
                  TextInputWidget(
                      label: "Confirme a senha",
                      passwordType: true,
                      onChanged: (value) {
                        _resetPasswordController.onChange(
                            confirmPassword: value);
                      },
                      controller: _confirmPassword,
                      validator: (value) => _resetPasswordController
                          .validateConfirmPassword(value, _password.text)),
                  const SizedBox(
                    height: 30,
                  ),
                  LabelButtonWidget(
                      onLoading: loading,
                      label: 'ENVIAR',
                      onPressed: handleSignUp),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
