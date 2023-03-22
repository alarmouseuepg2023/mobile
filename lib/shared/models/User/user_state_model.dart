// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:mobile/shared/models/User/user_model.dart';

class UserState {
  final User? user;
  final String? accessToken;
  final String? refreshToken;

  UserState({
    this.user,
    this.accessToken,
    this.refreshToken,
  });
}
