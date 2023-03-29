import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile/shared/models/Invite/invite_request_model.dart';
import 'package:mobile/shared/models/Invite/invite_response_model.dart';
import 'package:mobile/shared/models/Wifi/wifi_response_model.dart';
import 'package:mobile/shared/models/Wifi/wifi_resquest_model.dart';

import '../../service/index.dart';

class DeviceController {
  final formKey = GlobalKey<FormState>();
  final wifiFormKey = GlobalKey<FormState>();
  InviteRequest model = InviteRequest();
  WifiRequest wifiModel = WifiRequest();

  String? validateEmail(String? value) =>
      value?.isEmpty ?? true ? "O e-mail não pode ser vazio" : null;

  String? validateSsid(String? value) =>
      value?.isEmpty ?? true ? "O nome da rede não pode ser vazio" : null;

  String? validatePassword(String? value) =>
      value?.isEmpty ?? true ? "A senha da rede não pode ser vazio" : null;

  void onChange({String? email}) {
    model = model.copyWith(email: email);
  }

  void onChangeWifi({String? ssid, String? password}) {
    wifiModel = wifiModel.copyWith(ssid: ssid, password: password);
  }

  Future<InviteResponse?> inviteGuest(String deviceId) async {
    final formData = model.toJson();
    final form = formKey.currentState;

    if (form!.validate()) {
      final response = await dio.post('invite/$deviceId',
          data: formData, options: Options());
      InviteResponse data = InviteResponse.fromJson(response.data);
      return data;
    }
    return null;
  }

  Future<WifiResponse?> changeWifi(String deviceId) async {
    final formData = wifiModel.toJson();
    final form = wifiFormKey.currentState;

    if (form!.validate()) {
      print('entrei $formData');
    }
    return null;
  }
}
