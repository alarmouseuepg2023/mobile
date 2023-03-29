// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ResetPasswordRequest {
  final String? pin;
  final String? email;
  final String? password;
  final String? confirmPassword;
  ResetPasswordRequest({
    this.pin,
    this.email,
    this.password,
    this.confirmPassword,
  });

  ResetPasswordRequest copyWith({
    String? pin,
    String? email,
    String? password,
    String? confirmPassword,
  }) {
    return ResetPasswordRequest(
      pin: pin ?? this.pin,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'password': password,
      'pin': pin,
      'confirmPassword': confirmPassword,
    };
  }

  factory ResetPasswordRequest.fromMap(Map<String, dynamic> map) {
    return ResetPasswordRequest(
      email: map['email'] != null ? map['email'] as String : null,
      password: map['password'] != null ? map['password'] as String : null,
      pin: map['pin'] != null ? map['pin'] as String : null,
      confirmPassword: map['confirmPassword'] != null
          ? map['confirmPassword'] as String
          : null,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ResetPasswordRequest.fromJson(String source) =>
      ResetPasswordRequest.fromMap(jsonEncode(source) as Map<String, dynamic>);
}
