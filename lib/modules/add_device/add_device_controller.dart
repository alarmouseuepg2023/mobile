import 'package:flutter/cupertino.dart';
import 'package:mobile/shared/models/AddDevice/add_device_form_model.dart';

class AddDeviceController {
  final formKey = GlobalKey<FormState>();
  AddDeviceFormModel model = AddDeviceFormModel(wifiPassword: '');

  void onChange({String? wifiPassword}) {
    model = model.copyWith(
      wifiPassword: wifiPassword,
    );
  }

  bool validateDeviceForm() {
    final form = formKey.currentState;

    if (form!.validate()) {
      final formData = model.toJson();
      print(formData);
      return true;
    }
    return false;
  }
}
