import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/modules/delete_account/delete_account_controller.dart';
import 'package:mobile/providers/auth/auth_provider.dart';
import 'package:mobile/shared/utils/validators/input_validators.dart';
import 'package:mobile/shared/widgets/pin_input/pin_input_widget.dart';

import '../../shared/models/Response/server_response_model.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_text_styles.dart';
import '../../shared/widgets/label_button/label_button.dart';
import '../../shared/widgets/toast/toast_widget.dart';

class DeleteAccountPage extends ConsumerStatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  ConsumerState<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends ConsumerState<DeleteAccountPage> {
  final _deleteAccountController = DeleteAccountController();
  bool _loading = false;
  bool _mode = true;

  Future<void> handleRequestDelete() async {
    try {
      setState(() {
        _loading = true;
      });
      final res = await _deleteAccountController.requestDeleteAccount();
      if (res != null) {
        if (!mounted) return;

        final email = ref.read(authProvider).user!.email;
        GlobalToast.show(context, "Código de exclusão enviado para: $email.");
        setState(() {
          _mode = false;
        });
      }
    } catch (e) {
      if (e is DioError) {
        ServerResponse response = ServerResponse.fromJson(e.response?.data);
        GlobalToast.show(context, response.message);
      } else {
        GlobalToast.show(context,
            "Ocorreu um erro ao solicitar a exclusão. Tente novamente.");
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> handleConfirmDelete() async {
    try {
      setState(() {
        _loading = true;
      });
      final res = await _deleteAccountController.confirmDeleteAccount();
      if (res != null) {
        if (!mounted) return;

        ref.read(authProvider).clearUser();
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (e is DioError) {
        ServerResponse response = ServerResponse.fromJson(e.response?.data);
        GlobalToast.show(context, response.message);
      } else {
        GlobalToast.show(
            context, "Ocorreu um erro ao excluir a conta. Tente novamente.");
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_mode) {
          Navigator.pop(context);
        } else {
          setState(() {
            _mode = true;
          });
        }
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            shadowColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.primary),
            title: Text(
              "Excluir conta",
              style: TextStyles.register,
            ),
            centerTitle: true,
            leading: _mode
                ? null
                : InkWell(
                    onTap: (() {
                      setState(() {
                        _mode = true;
                      });
                    }),
                    child: const Icon(Icons.arrow_back)),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _mode
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Um código de 6 dígitos será enviado para seu email para prosseguir com a exclusão da conta. Caso já possua o código, basta escolher a opção "INSERIR CÓDIGO".',
                          style: TextStyles.inviteTextAnswerGoBack,
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        LabelButtonWidget(
                            onLoading: _loading,
                            label: 'SOLICITAR EXCLUSÃO',
                            onPressed: () {
                              handleRequestDelete();
                            }),
                        const SizedBox(
                          height: 10,
                        ),
                        LabelButtonWidget(
                            onLoading: _loading,
                            label: 'INSERIR CÓDIGO',
                            reversed: true,
                            onPressed: () {
                              setState(() {
                                _mode = false;
                              });
                            }),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          'A exclusão da conta é permanente, todos os dados e dispositivos serão perdidos!',
                          style: TextStyles.inviteAGuestBold,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Text(
                          "Código de exclusão",
                          style: TextStyles.input,
                          textAlign: TextAlign.start,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Form(
                          key: _deleteAccountController.formKey,
                          child: PinInputWidget(
                            onChanged: (value) {
                              _deleteAccountController.onChange(pin: value);
                            },
                            validator: validatePin,
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        LabelButtonWidget(
                            onLoading: _loading,
                            label: 'EXCLUIR CONTA',
                            onPressed: () {
                              handleConfirmDelete();
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
