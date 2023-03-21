import 'package:dio/dio.dart';
import 'package:mobile/shared/models/Login/login_request_model.dart';
import 'package:mobile/shared/models/Login/login_response_model.dart';

import '../../service/index.dart';

class LoginController {
  LoginRequest model = LoginRequest();

  void onChange({String? email, String? password}) {
    model = model.copyWith(email: email, password: password);
  }

  Future<LoginResponse> signIn() async {
    final formData = model.toJson();

    final response = await dio.post('auth', data: formData, options: Options());
    print(response);
    LoginResponse data = LoginResponse.fromJson(response.data);
    return data;
  }
}
