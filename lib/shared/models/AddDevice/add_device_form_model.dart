// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class AddDeviceFormModel {
  final String? wifiPassword;

  AddDeviceFormModel({
    this.wifiPassword,
  });

  AddDeviceFormModel copyWith({
    String? wifiPassword,
  }) {
    return AddDeviceFormModel(
      wifiPassword: wifiPassword ?? this.wifiPassword,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'wifiPassword': wifiPassword,
    };
  }

  String toJson() => jsonEncode(toMap());
}
