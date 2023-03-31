import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile/shared/models/Invite/invite_accept_request_model.dart';
import 'package:mobile/shared/models/Invite/invite_reject_request_model.dart';
import 'package:mobile/shared/models/Notifications/notifications_response_model.dart';
import 'package:mobile/shared/models/Response/server_response_model.dart';

import '../../service/index.dart';

class NotificationsController {
  final acceptFormKey = GlobalKey<FormState>();
  final rejectFormKey = GlobalKey<FormState>();
  InviteAcceptRequest inviteAcceptModel =
      InviteAcceptRequest(token: '', id: '', password: '', confirmPassword: '');
  InviteRejectRequest inviteRejectModel =
      InviteRejectRequest(token: '', id: '');

  void onChangeAccept(
      {String? token, String? id, String? password, String? confirmPassword}) {
    inviteAcceptModel = inviteAcceptModel.copyWith(
        token: token,
        id: id,
        password: password,
        confirmPassword: confirmPassword);
  }

  void onChangeReject({String? token, String? id}) {
    inviteRejectModel = inviteRejectModel.copyWith(
      token: token,
      id: id,
    );
  }

  Future<NotificationsResponse> getNotifications(int page, int size) async {
    final response =
        await dio.get('invite?page=$page&size=$size', options: Options());
    NotificationsResponse data = NotificationsResponse.fromJson(response.data);

    return data;
  }

  Future<ServerResponse?> acceptInvite() async {
    final formData = inviteAcceptModel.toJson();
    final form = acceptFormKey.currentState;

    if (form!.validate()) {
      final response =
          await dio.post('invite/accept', data: formData, options: Options());
      ServerResponse data = ServerResponse.fromJson(response.data);
      return data;
    }
    return null;
  }

  Future<ServerResponse?> rejectInvite() async {
    final formData = inviteRejectModel.toJson();
    final form = rejectFormKey.currentState;

    if (form!.validate()) {
      final response =
          await dio.post('invite/reject', data: formData, options: Options());
      ServerResponse data = ServerResponse.fromJson(response.data);
      return data;
    }
    return null;
  }
}
