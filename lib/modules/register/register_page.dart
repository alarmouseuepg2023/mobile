import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:mobile/modules/register/register_controller.dart';
import 'package:mobile/shared/themes/app_colors.dart';
import 'package:mobile/shared/themes/app_text_styles.dart';
import 'package:mobile/shared/utils/validators/input_validators.dart';
import 'package:mobile/shared/widgets/toast/toast_widget.dart';

import '../../shared/models/Response/server_response_model.dart';
import '../../shared/widgets/label_button/label_button.dart';
import '../../shared/widgets/text_input/text_input.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _registerController = RegisterController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  bool loading = false;

  Future<void> handleSignUp() async {
    try {
      setState(() {
        loading = true;
      });

      final res = await _registerController.createUser();

      if (res != null) {
        _password.clear();
        _confirmPassword.clear();
        if (!mounted) return;
        GlobalToast.show(context,
            res.message != "" ? res.message : "Usuário criado com sucesso!");
      }
    } catch (e) {
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
            "Cadastro",
            style: TextStyles.register,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _registerController.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextInputWidget(
                    label: "Nome",
                    onChanged: (value) {
                      _registerController.onChange(name: value);
                    },
                    validator: validateName,
                  ),
                  TextInputWidget(
                    label: "E-mail",
                    onChanged: (value) {
                      _registerController.onChange(email: value);
                    },
                    validator: (value) => EmailValidator.validate(value ?? '')
                        ? null
                        : "Insira um e-mail válido",
                  ),
                  TextInputWidget(
                      label: "Senha",
                      passwordType: true,
                      onChanged: (value) {
                        _registerController.onChange(password: value);
                      },
                      controller: _password,
                      validator: validatePassword),
                  TextInputWidget(
                      label: "Confirme a senha",
                      passwordType: true,
                      onChanged: (value) {
                        _registerController.onChange(confirmPassword: value);
                      },
                      controller: _confirmPassword,
                      validator: (value) =>
                          validateConfirmPassword(value, _password.text)),
                  const SizedBox(
                    height: 30,
                  ),
                  LabelButtonWidget(
                      onLoading: loading,
                      label: 'CADASTRAR',
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
