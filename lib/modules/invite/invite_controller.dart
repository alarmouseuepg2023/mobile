import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile/shared/models/Invite/invite_answer_response_model.dart';

import '../../service/index.dart';
import '../../shared/models/Invite/invite_accept_request_model.dart';
import '../../shared/models/Invite/invite_reject_request_model.dart';

class InviteController {
  List<GlobalKey<FormState>> acceptFormKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];
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

  Future<InviteAnswerResponse?> acceptInvite() async {
    final formData = inviteAcceptModel.toJson();
    final allFormValid =
        acceptFormKeys.every((element) => element.currentState!.validate());

    if (allFormValid) {
      final response =
          await dio.post('invite/accept', data: formData, options: Options());
      InviteAnswerResponse data = InviteAnswerResponse.fromJson(response.data);
      return data;
    }
    return null;
  }

  Future<InviteAnswerResponse?> rejectInvite() async {
    final formData = inviteRejectModel.toJson();
    final form = rejectFormKey.currentState;

    if (form!.validate()) {
      final response =
          await dio.post('invite/reject', data: formData, options: Options());
      InviteAnswerResponse data = InviteAnswerResponse.fromJson(response.data);
      return data;
    }
    return null;
  }
}
