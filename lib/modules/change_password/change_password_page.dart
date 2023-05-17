import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/modules/change_password/change_password_controller.dart';
import 'package:mobile/shared/utils/validators/input_validators.dart';
import 'package:mobile/shared/widgets/toast/toast_widget.dart';

import '../../shared/models/Response/server_response_model.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_text_styles.dart';
import '../../shared/widgets/label_button/label_button.dart';
import '../../shared/widgets/text_input/text_input.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePasswordPage> {
  final _changePasswordController = ChangePasswordController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  bool loading = false;

  Future<void> handleChangePassword() async {
    try {
      setState(() {
        loading = true;
      });

      final res = await _changePasswordController.createNewPassword();

      if (res != null) {
        _password.clear();
        _confirmPassword.clear();
        if (!mounted) return;
        GlobalToast.show(context,
            res.message != "" ? res.message : "Senha alterada com sucesso!");
      }
    } catch (e) {
      print(e);
      if (e is DioError) {
        ServerResponse response = ServerResponse.fromJson(e.response?.data);
        GlobalToast.show(
            context,
            response.message != ""
                ? response.message
                : "Ocorreu um erro ao entrar. Tente novamente.");
      } else {
        GlobalToast.show(
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
            "Alterar senha",
            style: TextStyles.register,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _changePasswordController.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextInputWidget(
                    label: "Senha antiga",
                    passwordType: true,
                    onChanged: (value) {
                      _changePasswordController.onChange(oldPassword: value);
                    },
                    validator: validatePassword,
                  ),
                  TextInputWidget(
                      label: "Nova senha",
                      passwordType: true,
                      onChanged: (value) {
                        _changePasswordController.onChange(password: value);
                      },
                      controller: _password,
                      validator: validatePassword),
                  TextInputWidget(
                      label: "Confirme a senha",
                      passwordType: true,
                      onChanged: (value) {
                        _changePasswordController.onChange(
                            confirmPassword: value);
                      },
                      controller: _confirmPassword,
                      validator: (value) =>
                          validateConfirmPassword(value, _password.text)),
                  const SizedBox(
                    height: 30,
                  ),
                  LabelButtonWidget(
                      onLoading: loading,
                      label: 'ALTERAR',
                      onPressed: handleChangePassword),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
