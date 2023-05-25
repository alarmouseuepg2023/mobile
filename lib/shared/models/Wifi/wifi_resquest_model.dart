// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class WifiRequest {
  final String? password;

  WifiRequest({
    this.password,
  });

  WifiRequest copyWith({
    String? password,
  }) {
    return WifiRequest(
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
