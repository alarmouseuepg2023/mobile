import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile/shared/models/AddDevice/add_device_form_model.dart';

import '../../service/index.dart';
import '../../shared/models/Response/server_response_model.dart';

class AddDeviceController {
  List<GlobalKey<FormState>> formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];
  AddDeviceFormModel model = AddDeviceFormModel(
      wifiPassword: '',
      nickname: '',
      ownerPassword: '',
      confirmOwnerPassword: '');

  void onChange(
      {String? wifiPassword,
      String? nickname,
      String? ownerPassword,
      String? confirmOwnerPassword}) {
    model = model.copyWith(
      wifiPassword: wifiPassword,
      nickname: nickname,
      ownerPassword: ownerPassword,
      confirmOwnerPassword: confirmOwnerPassword,
    );
  }

  bool validateDeviceForm() {
    final allFormValid =
        formKeys.every((element) => element.currentState!.validate());

    if (allFormValid) {
      return true;
    }
    return false;
  }

  Future<ServerResponse?> createDevice(
      String macAddress, String wifiSsid) async {
    final dio = DioApi().dio;
    final allFormValid =
        formKeys.every((element) => element.currentState!.validate());
    final deviceFormData = {
      'macAddress': macAddress,
      'wifiSsid': wifiSsid,
      'ownerPassword': model.ownerPassword,
      'nickname': model.nickname
    };
    if (allFormValid) {
      await dio.post('device', data: deviceFormData, options: Options());
      //ServerResponse data = ServerResponse.fromJson(response.data);
      return ServerResponse(
          message: "Operação realizada com sucesso",
          success: true,
          content: true);
    }
    return null;
  }
}
