import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile/modules/login/login_controller.dart';
import 'package:mobile/providers/auth/auth_provider.dart';
import 'package:mobile/shared/models/Response/server_response_model.dart';
import 'package:mobile/shared/models/User/user_model.dart';
import 'package:mobile/shared/themes/app_text_styles.dart';
import 'package:mobile/shared/utils/validators/input_validators.dart';
import 'package:mobile/shared/widgets/label_button/label_button.dart';
import 'package:mobile/shared/widgets/text_input/text_input.dart';
import 'package:mobile/shared/widgets/toast/toast_widget.dart';

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

        ref.read(authProvider).setUser(
            userData, res.content.refreshToken, res.content.accessToken);

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, "/home");
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
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/ALARMOUSE-LOGO-INVERTIDO-FUNDO-TRANSPARENTE.png',
                  height: 230,
                ),
                Text('Alarmouse', style: TextStyles.titleBig),
                const SizedBox(
                  height: 30,
                ),
                Form(
                    key: _loginController.formKey,
                    child: Column(
                      children: [
                        TextInputWidget(
                            label: "E-mail",
                            validator: validateEmail,
                            onChanged: (value) {
                              _loginController.onChange(email: value);
                            }),
                        TextInputWidget(
                            label: "Senha",
                            passwordType: true,
                            validator: validatePassword,
                            onChanged: (value) {
                              _loginController.onChange(password: value);
                            }),
                      ],
                    )),
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
                            Navigator.pushNamed(context, '/forgot_password');
                          },
                          child: Text("Esqueceu a senha?",
                              style: TextStyles.input)),
                    ),
                  ),
                ),
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
