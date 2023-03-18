import 'package:flutter/material.dart';
import 'package:mobile/shared/themes/app_text_styles.dart';
import 'package:mobile/shared/widgets/label_button/label_button.dart';
import 'package:mobile/shared/widgets/text_input/text_input.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                TextInputWidget(label: "E-mail", onChanged: (e) {}),
                TextInputWidget(label: "Senha", onChanged: (e) {}),
                const SizedBox(
                  height: 30,
                ),
                LabelButtonWidget(label: 'ENTRAR', onPressed: () {}),
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
