import 'package:flutter/material.dart';
import 'package:mobile/modules/forgot_device_password/forgot_device_password_controller.dart';
import 'package:mobile/shared/models/Device/device_model.dart';

import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_text_styles.dart';
import '../../shared/widgets/label_button/label_button.dart';

class ForgotDevicePasswordPage extends StatefulWidget {
  final Device device;
  const ForgotDevicePasswordPage({super.key, required this.device});

  @override
  State<ForgotDevicePasswordPage> createState() =>
      _ForgotDevicePasswordPageState();
}

class _ForgotDevicePasswordPageState extends State<ForgotDevicePasswordPage> {
  final _forgotDevicePasswordController = ForgotDevicePasswordController();
  bool loading = false;
  bool alreadyHasPin = false;

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
                    children: const [],
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
                                  Navigator.pushNamed(
                                      context, '/reset_password');
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
                          onPressed: () {}),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
