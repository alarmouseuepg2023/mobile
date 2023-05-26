// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ResetDeviceRequestModel {
  final String? wifiPassword;

  ResetDeviceRequestModel({this.wifiPassword});

  ResetDeviceRequestModel copyWith({
    String? wifiPassword,
  }) {
    return ResetDeviceRequestModel(
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
