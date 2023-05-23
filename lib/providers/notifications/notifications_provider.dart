import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Notification extends ChangeNotifier {
  int? notificationsCount = 0;
  int answerInviteMode = 0;

  void setNotifications(int count) {
    notificationsCount = count;
    //notifyListeners();
  }

  void setAnswerInviteMode(int mode) {
    answerInviteMode = mode;
    notifyListeners();
  }
}

final notificationsProvider = ChangeNotifierProvider((ref) {
  return Notification();
});
