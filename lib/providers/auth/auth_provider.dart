import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/models/User/user_model.dart';
import 'package:mobile/shared/models/User/user_state_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth extends Notifier<UserState> {
  User? user;
  String? refreshToken;
  String? accessToken;

  @override
  build() async {
    final pref = await SharedPreferences.getInstance();
    final userMap = pref.getString('ALARMOUSE:userData') ?? "";
    final storedRefreshToken = pref.getString('ALARMOUSE:refreshToken') ?? "";
    final storedAccessToken = pref.getString('ALARMOUSE:accessToken') ?? "";

    if (userMap != "" && storedAccessToken != "" && storedRefreshToken != "") {
      final userJson = User.fromJson(jsonDecode(userMap));

      refreshToken = storedRefreshToken;
      accessToken = storedAccessToken;
      user = userJson;

      return UserState(
          user: userJson, accessToken: accessToken, refreshToken: refreshToken);
    }

    return UserState(user: null, accessToken: null, refreshToken: null);
  }
}
