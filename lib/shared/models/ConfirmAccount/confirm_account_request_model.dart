// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ConfirmAccountRequest {
  final String? email;
  final String? pin;

  ConfirmAccountRequest({this.email, this.pin});

  ConfirmAccountRequest copyWith({String? email, String? pin}) {
    return ConfirmAccountRequest(
      email: email ?? this.email,
      pin: pin ?? this.pin,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'pin': pin,
    };
  }

  String toJson() => jsonEncode(toMap());
}
