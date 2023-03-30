import 'package:email_validator/email_validator.dart';

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

String? validateSsid(String? value) =>
    value?.isEmpty ?? true ? "O nome da rede não pode ser vazio" : null;

String? validateEmail(String? value) =>
    EmailValidator.validate(value ?? '') ? null : "Insira um e-mail válido";

String? validateName(String? value) =>
    value?.isEmpty ?? true ? "O nome não pode ser vazio" : null;
