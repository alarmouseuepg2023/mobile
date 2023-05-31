import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile/shared/models/ChangePassword/change_password_request_model.dart';
import 'package:mobile/shared/models/Device/device_nickname_request_model.dart';
import 'package:mobile/shared/models/Device/device_unlock_model.dart';
import 'package:mobile/shared/models/Invite/invite_request_model.dart';
import 'package:mobile/shared/models/Invite/invite_response_model.dart';
import 'package:mobile/shared/models/Response/server_response_model.dart';
import 'package:mobile/shared/models/Status/status_request_model.dart';
import 'package:mobile/shared/models/Status/status_response_model.dart';
import 'package:mobile/shared/models/Wifi/wifi_resquest_model.dart';

import '../../service/index.dart';

class DeviceController {
  final inviteFormKey = GlobalKey<FormState>();
  final wifiFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();
  final statusFormKey = GlobalKey<FormState>();
  final nicknameFormKey = GlobalKey<FormState>();

  StatusRequest statusModel = StatusRequest();
  InviteRequest inviteModel = InviteRequest();
  WifiRequest wifiModel = WifiRequest();
  ChangePasswordRequest passwordModel = ChangePasswordRequest();
  DeviceNicknameRequest nicknameModel = DeviceNicknameRequest();
  DeviceUnlock deviceUnlockModel = DeviceUnlock();

  void onChangeStatus({String? password, String? status}) {
    statusModel = statusModel.copyWith(password: password, status: status);
  }

  void onChangeDeviceUnlock({String? password}) {
    deviceUnlockModel = deviceUnlockModel.copyWith(password: password);
  }

  void onChangeInvite({String? email}) {
    inviteModel = inviteModel.copyWith(email: email);
  }

  void onChangeNickname({String? nickname}) {
    nicknameModel = nicknameModel.copyWith(nickname: nickname);
  }

  void onChangeWifi({String? password}) {
    wifiModel = wifiModel.copyWith(password: password);
  }

  void onChangePassword(
      {String? oldPassword, String? password, String? confirmPassword}) {
    passwordModel = passwordModel.copyWith(
        oldPassword: oldPassword,
        password: password,
        confirmPassword: confirmPassword);
  }

  Future<StatusResponseModel?> changeStatus(String deviceId) async {
    final dio = DioApi().dio;
    final formData = {
      'status': statusModel.status,
      'password': deviceUnlockModel.password
    };

    final response = await dio.post('device/status/$deviceId',
        data: formData, options: Options());

    StatusResponseModel data = StatusResponseModel.fromJson(response.data);
    return data;
  }

  Future<InviteResponse?> inviteGuest(String deviceId) async {
    final dio = DioApi().dio;
    final formData = inviteModel.toJson();
    final form = inviteFormKey.currentState;

    if (form!.validate()) {
      final response = await dio.post('invite/$deviceId',
          data: formData, options: Options());
      InviteResponse data = InviteResponse.fromJson(response.data);
      return data;
    }
    return null;
  }

  Future<ServerResponse?> changeNickname(String deviceId) async {
    final dio = DioApi().dio;
    final formData = nicknameModel.toJson();
    final form = nicknameFormKey.currentState;

    if (form!.validate()) {
      await dio.patch('device/changeNickname/$deviceId',
          data: formData, options: Options());
      //ServerResponse data = ServerResponse.fromJson(response.data);
      return ServerResponse(
          message: "Operação realizada com sucesso",
          success: true,
          content: true);
    }
    return null;
  }

  Future<ServerResponse?> changePassword(String deviceId) async {
    final dio = DioApi().dio;
    final formData = passwordModel.toJson();
    final form = passwordFormKey.currentState;

    if (form!.validate()) {
      final response = await dio.post('device/changePassword/$deviceId',
          data: formData, options: Options());
      ServerResponse data = ServerResponse.fromJson(response.data);
      return data;
    }
    return null;
  }

  Future<StatusResponseModel?> wifiResetStarted(String deviceId) async {
    final dio = DioApi().dio;
    final formData = deviceUnlockModel.toJson();

    final response = await dio.post('device/wifiChangeHaveStarted/$deviceId',
        data: formData, options: Options());
    StatusResponseModel data = StatusResponseModel.fromJson(response.data);
    return data;
  }

  Future<ServerResponse?> deleteDevice(String deviceId) async {
    final dio = DioApi().dio;
    final response = await dio.delete('device/$deviceId', options: Options());
    ServerResponse data = ServerResponse.fromJson(response.data);

    return data;
  }
}
