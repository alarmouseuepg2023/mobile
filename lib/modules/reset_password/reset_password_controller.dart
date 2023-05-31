import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile/shared/models/ResetPassword/reset_password_request_model.dart';
import 'package:mobile/shared/models/Response/server_response_model.dart';

import '../../service/index.dart';

class ResetPasswordContorller {
  final formKey = GlobalKey<FormState>();
  ResetPasswordRequest model = ResetPasswordRequest();

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
    final dio = DioApi().dio;
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
