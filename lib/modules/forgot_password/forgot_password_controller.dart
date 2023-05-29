import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile/shared/models/ForgotPassword/forgot_password_request_model.dart';
import 'package:mobile/shared/models/Response/server_response_model.dart';

import '../../service/index.dart';

class ForgotPasswordController {
  final formKey = GlobalKey<FormState>();
  ForgotPasswordRequest model = ForgotPasswordRequest(email: '');

  void onChange({
    String? email,
  }) {
    model = model.copyWith(
      email: email,
    );
  }

  Future<ServerResponse> signUp() async {
    final dio = DioApi().dio;
    final formData = model.toJson();

    final response = await dio.post('auth/forgotPassword',
        data: formData, options: Options());

    ServerResponse data = ServerResponse.fromJson(response.data);

    formKey.currentState!.reset();

    return data;
  }

  Future<ServerResponse?> createUser() async {
    final form = formKey.currentState;

    if (form!.validate()) {
      return signUp();
    }
    return null;
  }
}
