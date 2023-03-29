import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile/shared/models/ChangePassword/change_password_request_model.dart';
import 'package:mobile/shared/models/Response/server_response_model.dart';

import '../../service/index.dart';

class ChangePasswordController {
  final formKey = GlobalKey<FormState>();
  ChangePasswordRequest model =
      ChangePasswordRequest(oldPassword: '', password: '', confirmPassword: '');

  String? validatePassword(String? value) {
    if (value!.isEmpty) return "A senha não pode ser vazia";

    if (value.length < 8) return "A senha precisa conter mais de 8 caracteres";

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

  void onChange(
      {String? oldPassword, String? password, String? confirmPassword}) {
    model = model.copyWith(
        oldPassword: oldPassword,
        password: password,
        confirmPassword: confirmPassword);
  }

  Future<ServerResponse> changePassword() async {
    final formData = model.toJson();

    final response = await dio.post('user/changePassword',
        data: formData, options: Options());

    ServerResponse data = ServerResponse.fromJson(response.data);

    formKey.currentState!.reset();

    return data;
  }

  Future<ServerResponse?> createNewPassword() async {
    final form = formKey.currentState;

    if (form!.validate()) {
      return changePassword();
    }
    return null;
  }
}
