// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class InviteRejectRequest {
  final String token;
  final String id;

  InviteRejectRequest({
    required this.token,
    required this.id,
  });

  InviteRejectRequest copyWith({
    String? token,
    String? id,
  }) {
    return InviteRejectRequest(
      token: token ?? this.token,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'token': token,
      'id': id,
    };
  }

  String toJson() => jsonEncode(toMap());
}
