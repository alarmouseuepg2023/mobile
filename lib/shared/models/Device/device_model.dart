// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:mobile/shared/models/User/user_model.dart';

class Device {
  final String id;
  final String macAddress;
  final String nickname;
  final String wifiSsid;
  final bool locked;
  final User owner;

  Device({
    required this.id,
    required this.macAddress,
    required this.nickname,
    required this.wifiSsid,
    required this.locked,
    required this.owner,
  });
}
