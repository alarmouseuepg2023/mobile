import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile/service/index.dart';
import 'package:mobile/shared/models/ResetDevicePassword/reset_device_password_request_model.dart';
import 'package:mobile/shared/models/Response/server_response_model.dart';

class ForgotDevicePasswordController {
  final passwordFormKey = GlobalKey<FormState>();
  final dio = DioApi().dio;
  ResetDevicePasswordRequest passwordModel = ResetDevicePasswordRequest();

  void onChangePassword(
      {String? pin, String? password, String? confirmPassword}) {
    passwordModel = passwordModel.copyWith(
        pin: pin, password: password, confirmPassword: confirmPassword);
  }

  Future<ServerResponse?> forgotDevicePassword(String deviceId) async {
    final response =
        await dio.post('device/forgotPassword/$deviceId', options: Options());
    ServerResponse data = ServerResponse.fromJson(response.data);
    return data;
  }

  Future<ServerResponse?> resetDevicePassword(String deviceId) async {
    final formData = passwordModel.toJson();
    final form = passwordFormKey.currentState;

    if (form!.validate()) {
      final response = await dio.post('device/resetPassword/$deviceId',
          data: formData, options: Options());
      ServerResponse data = ServerResponse.fromJson(response.data);
      return data;
    }
    return null;
  }
}
