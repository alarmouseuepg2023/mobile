// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ForgotPasswordRequest {
  final String? email;

  ForgotPasswordRequest({
    this.email,
  });

  ForgotPasswordRequest copyWith({
    String? email,
  }) {
    return ForgotPasswordRequest(
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
    };
  }

  String toJson() => jsonEncode(toMap());
}
