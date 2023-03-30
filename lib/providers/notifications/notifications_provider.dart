import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Notification extends ChangeNotifier {
  int? notificationsCount = 0;

  void setNotifications(int count) async {
    notificationsCount = count;
    notifyListeners();
  }
}

final notificationsProvider = ChangeNotifierProvider((ref) {
  return Notification();
});
