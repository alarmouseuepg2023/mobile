import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile/shared/models/ResetPassword/reset_password_request_model.dart';
import 'package:mobile/shared/models/Response/server_response_model.dart';

import '../../service/index.dart';

class ResetPasswordContorller {
  final formKey = GlobalKey<FormState>();
  ResetPasswordRequest model = ResetPasswordRequest();

  String? validatePassword(String? value) {
    if (value!.isEmpty) return "A senha não pode ser vazia";

    if (value.length < 8) return "A senha precisa conter mais de 8 caracteres";

    return null;
  }

  String? validatePin(String? value) {
    if (value!.isEmpty) return "O código não pode ser vazio";

    if (value.length < 6) return "O código deve ter 6 dígitos";

    return null;
  }

  String? validateConfirmPassword(String? value, String? passwordValue) {
    if (value!.isEmpty) return "A confirmação da senha não pode ser vazia";

    if (value.length < 8) {
      return "A confirmação da senha precisa conter mais de 8 caracteres";
    }
    if (value != passwordValue) return "As senhas não coincidem";

    return null;
  }

  void onChange({
    String? email,
    String? pin,
    String? password,
    String? confirmPassword,
  }) {
    model = model.copyWith(
      email: email,
      pin: pin,
      password: password,
      confirmPassword: confirmPassword,
    );
  }

  Future<ServerResponse> resetPassword() async {
    final formData = model.toJson();

    final response = await dio.post('auth/resetPassword',
        data: formData, options: Options());

    ServerResponse data = ServerResponse.fromJson(response.data);

    formKey.currentState!.reset();

    return data;
  }

  Future<ServerResponse?> createResetPassword() async {
    final form = formKey.currentState;

    if (form!.validate()) {
      return resetPassword();
    }
    return null;
  }
}
