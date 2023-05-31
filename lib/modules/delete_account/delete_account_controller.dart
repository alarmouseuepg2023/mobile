import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile/shared/models/User/user_delete_confirm_request_model.dart';

import '../../service/index.dart';
import '../../shared/models/Response/server_response_model.dart';

class DeleteAccountController {
  final formKey = GlobalKey<FormState>();
  UserDeleteConfirmRequest model = UserDeleteConfirmRequest(pin: '');

  void onChange({String? pin}) {
    model = model.copyWith(
      pin: pin,
    );
  }

  Future<ServerResponse?> requestDeleteAccount() async {
    final dio = DioApi().dio;
    final response = await dio.post('user/delete/request', options: Options());
    ServerResponse data = ServerResponse.fromJson(response.data);
    return data;
  }

  Future<ServerResponse?> confirmDeleteAccount() async {
    final dio = DioApi().dio;
    final form = formKey.currentState;

    if (form!.validate()) {
      final response = await dio.delete('user/delete/confirm/${model.pin}',
          options: Options());
      ServerResponse data = ServerResponse.fromJson(response.data);
      return data;
    }
    return null;
  }
}
