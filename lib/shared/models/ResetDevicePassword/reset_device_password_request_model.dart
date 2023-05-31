// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ResetDevicePasswordRequest {
  final String? pin;
  final String? password;
  final String? confirmPassword;

  ResetDevicePasswordRequest({
    this.pin,
    this.password,
    this.confirmPassword,
  });

  ResetDevicePasswordRequest copyWith({
    String? pin,
    String? password,
    String? confirmPassword,
  }) {
    return ResetDevicePasswordRequest(
      pin: pin ?? this.pin,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pin': pin,
      'password': password,
      'confirmPassword': confirmPassword,
    };
  }

  factory ResetDevicePasswordRequest.fromMap(Map<String, dynamic> map) {
    return ResetDevicePasswordRequest(
      pin: map['pin'] != null ? map['pin'] as String : null,
      password: map['password'] != null ? map['password'] as String : null,
      confirmPassword: map['confirmPassword'] != null
          ? map['confirmPassword'] as String
          : null,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ResetDevicePasswordRequest.fromJson(String source) =>
      ResetDevicePasswordRequest.fromMap(
          jsonEncode(source) as Map<String, dynamic>);
}
