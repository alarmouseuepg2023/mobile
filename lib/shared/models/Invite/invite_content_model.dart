// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class InviteContent {
  final String id;
  final String status;
  final String invitedAt;

  InviteContent({
    required this.id,
    required this.status,
    required this.invitedAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'status': status,
      'invitedAt': invitedAt,
    };
  }

  factory InviteContent.fromMap(Map<String, dynamic> map) => InviteContent(
        id: map['id'] as String,
        status: map['status'] as String,
        invitedAt: map['invitedAt'] as String,
      );

  String toJson() => jsonEncode(toMap());

  factory InviteContent.fromJson(Map<String, dynamic> json) => InviteContent(
        id: json['id'],
        status: json['status'],
        invitedAt: json['invitedAt'],
      );

  @override
  String toString() => '{ id: $id, status: $status , invitedAt: $invitedAt }';
}
