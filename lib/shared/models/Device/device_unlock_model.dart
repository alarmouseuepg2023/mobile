// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class DeviceUnlock {
  final String? password;

  DeviceUnlock({
    this.password,
  });

  DeviceUnlock copyWith({
    String? password,
  }) {
    return DeviceUnlock(
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'password': password,
    };
  }

  String toJson() => jsonEncode(toMap());
}
