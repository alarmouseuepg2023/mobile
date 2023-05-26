import 'package:flutter/cupertino.dart';
import 'package:mobile/shared/models/ResetDevice/reset_device_request_model.dart';

class ResetDeviceController {
  List<GlobalKey<FormState>> formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];
  ResetDeviceRequestModel model = ResetDeviceRequestModel(wifiPassword: '');

  void onChange({
    String? wifiPassword,
  }) {
    model = model.copyWith(
      wifiPassword: wifiPassword,
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
}
