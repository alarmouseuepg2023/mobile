import 'package:flutter/material.dart';
import 'package:mobile/shared/models/User/user_register_model.dart';

class RegisterController {
  final formKey = GlobalKey<FormState>();
  UserRegister model =
      UserRegister(name: '', email: '', password: '', confirmPassword: '');

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

  Future<void> signUp() async {
    final formData = model.toJson();
    print(formData);

    //final response = await dio.post('auth', data: formData, options: Options());

    //LoginResponseModel data = LoginResponseModel.fromJson(response.data);

    return;
  }

  Future<void> createUser() async {
    final form = formKey.currentState;

    if (form!.validate()) {
      return signUp();
    }
  }
}
