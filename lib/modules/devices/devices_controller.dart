import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile/shared/models/Device/device_unlock_model.dart';
import 'package:mobile/shared/models/Response/server_response_model.dart';

import '../../service/index.dart';
import '../../shared/models/Device/device_response_model.dart';

class DevicesController {
  final unlockDeviceFormKey = GlobalKey<FormState>();
  DeviceUnlock unlockDeviceModel = DeviceUnlock();

  void onChangeUnlock({String? password}) {
    unlockDeviceModel = unlockDeviceModel.copyWith(password: password);
  }

  Future<DeviceResponse> getDevices(int page, int size) async {
    final response =
        await dio.get('device?page=$page&size=$size', options: Options());

    DeviceResponse data = DeviceResponse.fromJson(response.data);

    return data;
  }

  Future<ServerResponse?> unlockDevice(String deviceId) async {
    final formData = unlockDeviceModel.toJson();
    final form = unlockDeviceFormKey.currentState;

    if (form!.validate()) {
      final response = await dio.post('device/authentication/$deviceId',
          options: Options(), data: formData);

      ServerResponse data = ServerResponse.fromJson(response.data);
      return data;
    }
    return null;
  }
}
