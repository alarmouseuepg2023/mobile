import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/models/User/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth extends ChangeNotifier {
  User? user;
  String? refreshToken;
  String? accessToken;

  Future<bool> getUserData() async {
    final pref = await SharedPreferences.getInstance();
    final userMap = pref.getString('ALARMOUSE:userData') ?? "";
    final storedRefreshToken = pref.getString('ALARMOUSE:refreshToken') ?? "";
    final storedAccessToken = pref.getString('ALARMOUSE:accessToken') ?? "";
    if (userMap != "" && storedAccessToken != "" && storedRefreshToken != "") {
      final userJson = User.fromJson(jsonDecode(userMap));

      refreshToken = storedRefreshToken;
      accessToken = storedAccessToken;
      user = userJson;
      notifyListeners();

      return true;
    }

    return false;
  }

  void setUser(User? newUser, String refreshToken, String accessToken) async {
    if (newUser != null) {
      final pref = await SharedPreferences.getInstance();
      pref.setString("ALARMOUSE:userData", jsonEncode(newUser));
      pref.setString("ALARMOUSE:refreshToken", refreshToken);
      pref.setString("ALARMOUSE:accessToken", accessToken);

      user = newUser;
      refreshToken = refreshToken;
      accessToken = accessToken;

      notifyListeners();
    }
  }

  void clearUser() async {
    final pref = await SharedPreferences.getInstance();

    pref.clear();
    notifyListeners();
  }
}

final authProvider = ChangeNotifierProvider((ref) {
  return Auth();
});
