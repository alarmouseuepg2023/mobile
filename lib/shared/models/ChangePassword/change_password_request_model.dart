// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ChangePasswordRequest {
  final String? oldPassword;
  final String? password;
  final String? confirmPassword;

  ChangePasswordRequest({
    this.oldPassword,
    this.password,
    this.confirmPassword,
  });

  ChangePasswordRequest copyWith({
    String? oldPassword,
    String? password,
    String? confirmPassword,
  }) {
    return ChangePasswordRequest(
      oldPassword: oldPassword ?? this.oldPassword,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'oldPassword': oldPassword,
      'password': password,
      'confirmPassword': confirmPassword,
    };
  }

  factory ChangePasswordRequest.fromMap(Map<String, dynamic> map) {
    return ChangePasswordRequest(
      oldPassword:
          map['oldPassword'] != null ? map['oldPassword'] as String : null,
      password: map['password'] != null ? map['password'] as String : null,
      confirmPassword: map['confirmPassword'] != null
          ? map['confirmPassword'] as String
          : null,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ChangePasswordRequest.fromJson(String source) =>
      ChangePasswordRequest.fromMap(jsonEncode(source) as Map<String, dynamic>);
}
