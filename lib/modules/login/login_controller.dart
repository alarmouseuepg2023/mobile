import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/shared/models/Login/login_request_model.dart';
import 'package:mobile/shared/models/Login/login_response_model.dart';

import '../../service/index.dart';

class LoginController {
  final formKey = GlobalKey<FormState>();
  LoginRequest model = LoginRequest();

  void onChange({String? email, String? password}) {
    model = model.copyWith(email: email, password: password);
  }

  Future<LoginResponse?> signIn() async {
    final dio = DioApi().dio;
    final formData = model.toJson();
    final form = formKey.currentState;

    if (form!.validate()) {
      final response =
          await dio.post('auth', data: formData, options: Options());
      LoginResponse data = LoginResponse.fromJson(response.data);
      return data;
    }
    return null;
  }
}
