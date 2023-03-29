// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class InviteRequest {
  final String? email;

  InviteRequest({this.email});

  InviteRequest copyWith({
    String? email,
  }) {
    return InviteRequest(
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
