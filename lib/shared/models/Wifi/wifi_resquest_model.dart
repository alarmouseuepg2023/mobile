// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class WifiRequest {
  final String? ssid;
  final String? password;

  WifiRequest({
    this.ssid,
    this.password,
  });

  WifiRequest copyWith({
    String? ssid,
    String? password,
  }) {
    return WifiRequest(
      ssid: ssid ?? this.ssid,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ssid': ssid,
      'password': password,
    };
  }

  String toJson() => jsonEncode(toMap());
}
