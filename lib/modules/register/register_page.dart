import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:mobile/modules/register/register_controller.dart';
import 'package:mobile/shared/themes/app_colors.dart';
import 'package:mobile/shared/themes/app_text_styles.dart';

import '../../shared/widgets/label_button/label_button.dart';
import '../../shared/widgets/text_input/text_input.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final registerController = RegisterController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

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
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: registerController.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextInputWidget(
                    label: "Nome",
                    onChanged: (value) {
                      registerController.onChange(name: value);
                    },
                    validator: registerController.validateName,
                  ),
                  TextInputWidget(
                    label: "E-mail",
                    onChanged: (value) {
                      registerController.onChange(email: value);
                    },
                    validator: (value) => EmailValidator.validate(value ?? '')
                        ? null
                        : "Insira um e-mail válido",
                  ),
                  TextInputWidget(
                      label: "Senha",
                      onChanged: (value) {
                        registerController.onChange(password: value);
                      },
                      controller: _password,
                      validator: registerController.validatePassword),
                  TextInputWidget(
                      label: "Confirme a senha",
                      onChanged: (value) {
                        registerController.onChange(confirmPassword: value);
                      },
                      controller: _confirmPassword,
                      validator: (value) => registerController
                          .validateConfirmPassword(value, _password.text)),
                  const SizedBox(
                    height: 30,
                  ),
                  LabelButtonWidget(
                      label: 'CADASTRAR',
                      onPressed: () async {
                        await registerController.createUser();
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
