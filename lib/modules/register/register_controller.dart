import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/shared/models/Register/register_request_model.dart';
import 'package:mobile/shared/models/Register/register_response_model.dart';

import '../../service/index.dart';

class RegisterController {
  final formKey = GlobalKey<FormState>();
  RegisterRequest model =
      RegisterRequest(name: '', email: '', password: '', confirmPassword: '');

  String? validateName(String? value) =>
      value?.isEmpty ?? true ? "O nome não pode ser vazio" : null;

  String? validateEmail(String? value) =>
      value?.isEmpty ?? true ? "O e-mail não pode ser vazio" : null;

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
