import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile/modules/login/login_controller.dart';
import 'package:mobile/providers/auth/auth_provider.dart';
import 'package:mobile/shared/models/Response/response_model.dart';
import 'package:mobile/shared/models/User/user_model.dart';
import 'package:mobile/shared/themes/app_text_styles.dart';
import 'package:mobile/shared/widgets/label_button/label_button.dart';
import 'package:mobile/shared/widgets/text_input/text_input.dart';

import '../../service/index.dart';
import '../../shared/widgets/snackbar/snackbar_widget.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _loginController = LoginController();
  bool loading = false;

  Future<void> handleSignIn(BuildContext context) async {
    try {
      setState(() {
        loading = true;
      });

      final res = await _loginController.signIn();

      if (res != null) {
        Map<String, dynamic> decodedAccessToken =
            JwtDecoder.decode(res.content.accessToken);

        User userData = User.fromMap(decodedAccessToken);

        dio.options.headers[HttpHeaders.authorizationHeader] =
            "bearer ${res.content.accessToken}";

        ref.read(authProvider).setUser(
            userData, res.content.refreshToken, res.content.accessToken);

        if (!mounted) return;
        Navigator.of(context)
            .pushReplacementNamed("/home", arguments: res.content);
      }
    } catch (e) {
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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/ALARMOUSE-LOGO-INVERTIDO-FUNDO-TRANSPARENTE.png',
                  height: 250,
                ),
                Text('Alarmouse', style: TextStyles.titleBig),
                const SizedBox(
                  height: 30,
                ),
                Form(
                    key: _loginController.formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        TextInputWidget(
                            label: "E-mail",
                            validator: _loginController.validateEmail,
                            onChanged: (value) {
                              _loginController.onChange(email: value);
                            }),
                        TextInputWidget(
                            label: "Senha",
                            validator: _loginController.validatePassword,
                            onChanged: (value) {
                              _loginController.onChange(password: value);
                            }),
                      ],
                    )),
                const SizedBox(
                  height: 30,
                ),
                LabelButtonWidget(
                    label: 'ENTRAR',
                    onLoading: loading,
                    onPressed: () {
                      handleSignIn(context);
                    }),
                const SizedBox(
                  height: 20,
                ),
                LabelButtonWidget(
                    label: 'CADASTRAR',
                    reversed: true,
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
