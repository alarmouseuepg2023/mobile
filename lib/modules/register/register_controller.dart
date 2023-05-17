import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/shared/models/Register/register_request_model.dart';
import 'package:mobile/shared/models/Register/register_response_model.dart';

import '../../service/index.dart';

class RegisterController {
  final formKey = GlobalKey<FormState>();
  RegisterRequest model =
      RegisterRequest(name: '', email: '', password: '', confirmPassword: '');

  void onChange(
      {String? name,
      String? email,
      String? password,
      String? confirmPassword}) {
    model = model.copyWith(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword);
  }

  Future<RegisterResponse> signUp() async {
    final formData = model.toJson();

    final response = await dio.post('user', data: formData, options: Options());

    RegisterResponse data = RegisterResponse.fromJson(response.data);

    formKey.currentState!.reset();

    return data;
  }

  Future<RegisterResponse?> createUser() async {
    final form = formKey.currentState;

    if (form!.validate()) {
      return signUp();
    }
    return null;
  }
}
