import 'package:flutter/material.dart';

import '../../shared/widgets/label_button/label_button.dart';
import '../../shared/widgets/text_input/text_input.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
                TextInputWidget(label: "E-mail", onChanged: (e) {}),
                TextInputWidget(label: "Senha", onChanged: (e) {}),
                const SizedBox(
                  height: 30,
                ),
                LabelButtonWidget(label: 'ENTRAR', onPressed: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
