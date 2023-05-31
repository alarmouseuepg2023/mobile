import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile/shared/models/ConfirmAccount/confirm_account_request_model.dart';
import 'package:mobile/shared/models/Login/login_response_model.dart';

import '../../service/index.dart';

class ConfirmAccountController {
  final formKey = GlobalKey<FormState>();
  ConfirmAccountRequest model = ConfirmAccountRequest(email: '');

  void onChange({
    String? email,
    String? pin,
  }) {
    model = model.copyWith(
      email: email,
      pin: pin,
    );
  }

  Future<LoginResponse> confirmAccount() async {
    final dio = DioApi().dio;
    final formData = model.toJson();

    final response =
        await dio.post('user/confirm', data: formData, options: Options());

    LoginResponse data = LoginResponse.fromJson(response.data);

    formKey.currentState!.reset();

    return data;
  }

  Future<LoginResponse?> createConfirmation() async {
    final form = formKey.currentState;

    if (form!.validate()) {
      return confirmAccount();
    }
    return null;
  }
}
