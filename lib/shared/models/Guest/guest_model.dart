// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:mobile/shared/models/Device/device_model.dart';
import 'package:mobile/shared/models/User/user_model.dart';

class Guest {
  final String id;
  final User user;
  final Device device;

  Guest({
    required this.id,
    required this.user,
    required this.device,
  });
}
