import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile/modules/confirm_account/confirm_account_controller.dart';
import 'package:mobile/providers/auth/auth_provider.dart';
import 'package:mobile/shared/utils/validators/input_validators.dart';
import 'package:mobile/shared/widgets/toast/toast_widget.dart';

import '../../shared/models/Response/server_response_model.dart';
import '../../shared/models/User/user_model.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_text_styles.dart';
import '../../shared/widgets/label_button/label_button.dart';
import '../../shared/widgets/pin_input/pin_input_widget.dart';
import '../../shared/widgets/text_input/text_input.dart';

class ConfirmAccountPage extends ConsumerStatefulWidget {
  final String? email;
  const ConfirmAccountPage({super.key, this.email});

  @override
  ConsumerState<ConfirmAccountPage> createState() => _ConfirmAccountPageState();
}

class _ConfirmAccountPageState extends ConsumerState<ConfirmAccountPage> {
  bool loading = false;
  final _confirmAccountController = ConfirmAccountController();
  final _email = TextEditingController();

  @override
  void initState() {
    _email.text = widget.email ?? "";
    _confirmAccountController.onChange(email: widget.email ?? "");
    super.initState();
  }

  Future<void> handleAccountConfirmation() async {
    try {
      setState(() {
        loading = true;
      });

      final res = await _confirmAccountController.createConfirmation();

      if (res != null) {
        Map<String, dynamic> decodedAccessToken =
            JwtDecoder.decode(res.content.accessToken);

        User userData = User.fromMap(decodedAccessToken);

        ref.read(authProvider).setUser(
            userData, res.content.refreshToken, res.content.accessToken);
        if (!mounted) return;
        GlobalToast.show(context,
            "Usuário confirmado com sucesso! Você será logado automaticamente.");

        Navigator.pushReplacementNamed(context, "/home");
      }
    } catch (e) {
      if (e is DioError) {
        ServerResponse response = ServerResponse.fromJson(e.response?.data);
        GlobalToast.show(
            context,
            response.message != ""
                ? response.message
                : "Ocorreu um erro ao confirmar o usuário. Tente novamente.");
      } else {
        GlobalToast.show(context,
            "Ocorreu um erro ao confirmar o usuário. Tente novamente.");
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
            "Confirmar conta",
            style: TextStyles.register,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _confirmAccountController.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Enviamos um código de 6 dígitos para seu e-mail. Insira-o para ativar sua conta e começar a usar o app!",
                    style: TextStyles.inviteAGuestBold,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextInputWidget(
                      label: "E-mail",
                      controller: _email,
                      onChanged: (value) {
                        _confirmAccountController.onChange(email: value);
                      },
                      validator: validateEmail),
                  const SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Código de confirmação",
                    style: TextStyles.inviteText,
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  PinInputWidget(
                    onChanged: (value) {
                      _confirmAccountController.onChange(pin: value);
                    },
                    validator: validatePin,
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  LabelButtonWidget(
                      onLoading: loading,
                      label: 'ENVIAR',
                      onPressed: handleAccountConfirmation),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
