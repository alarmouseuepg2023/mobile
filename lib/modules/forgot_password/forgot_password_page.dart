import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/modules/forgot_password/forgot_password_controller.dart';
import 'package:mobile/shared/utils/validators/input_validators.dart';

import '../../shared/models/Response/server_response_model.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_text_styles.dart';
import '../../shared/widgets/label_button/label_button.dart';
import '../../shared/widgets/snackbar/snackbar_widget.dart';
import '../../shared/widgets/text_input/text_input.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  bool loading = false;
  final _forgotPasswordController = ForgotPasswordController();

  Future<void> handleSignUp() async {
    try {
      setState(() {
        loading = true;
      });

      final res = await _forgotPasswordController.createUser();

      if (res != null) {
        if (!mounted) return;
        GlobalSnackBar.show(context,
            res.message != "" ? res.message : "Usuário criado com sucesso!");
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
            "Esqueci a senha",
            style: TextStyles.register,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _forgotPasswordController.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextInputWidget(
                      label: "E-mail",
                      onChanged: (value) {
                        _forgotPasswordController.onChange(email: value);
                      },
                      validator: validateEmail),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Align(
                      alignment: FractionalOffset.bottomRight,
                      child: Ink(
                        child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/reset_password');
                            },
                            child: Text("Já possuo um código",
                                style: TextStyles.input)),
                      ),
                    ),
                  ),
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
