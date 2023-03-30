import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile/shared/models/ChangePassword/change_password_request_model.dart';
import 'package:mobile/shared/models/Response/server_response_model.dart';

import '../../service/index.dart';

class ChangePasswordController {
  final formKey = GlobalKey<FormState>();
  ChangePasswordRequest model =
      ChangePasswordRequest(oldPassword: '', password: '', confirmPassword: '');

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
