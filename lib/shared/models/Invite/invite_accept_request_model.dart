// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class InviteAcceptRequest {
  final String token;
  final String id;
  final String password;
  final String confirmPassword;

  InviteAcceptRequest({
    required this.token,
    required this.id,
    required this.password,
    required this.confirmPassword,
  });

  InviteAcceptRequest copyWith({
    String? token,
    String? id,
    String? password,
    String? confirmPassword,
  }) {
    return InviteAcceptRequest(
      token: token ?? this.token,
      id: id ?? this.id,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'token': token,
      'id': id,
      'password': password,
      'confirmPassword': confirmPassword,
    };
  }

  String toJson() => jsonEncode(toMap());
}
