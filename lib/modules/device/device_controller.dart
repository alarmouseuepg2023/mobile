import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile/shared/models/Invite/invite_request_model.dart';
import 'package:mobile/shared/models/Invite/invite_response_model.dart';

import '../../service/index.dart';

class DeviceController {
  final formKey = GlobalKey<FormState>();
  InviteRequest model = InviteRequest();

  String? validateEmail(String? value) =>
      value?.isEmpty ?? true ? "O e-mail não pode ser vazio" : null;

  void onChange({String? email}) {
    model = model.copyWith(email: email);
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
}
