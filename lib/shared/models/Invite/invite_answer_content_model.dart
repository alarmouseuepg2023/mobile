// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class InviteAnswerContent {
  final String id;
  final String status;
  final String invitedAt;
  final String answeredAt;

  InviteAnswerContent(
      {required this.id,
      required this.status,
      required this.invitedAt,
      required this.answeredAt});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'status': status,
      'invitedAt': invitedAt,
      'answeredAt': answeredAt,
    };
  }

  factory InviteAnswerContent.fromMap(Map<String, dynamic> map) =>
      InviteAnswerContent(
        id: map['id'] as String,
        status: map['status'] as String,
        invitedAt: map['invitedAt'] as String,
        answeredAt: map['answeredAt'] as String,
      );

  String toJson() => jsonEncode(toMap());

  factory InviteAnswerContent.fromJson(Map<String, dynamic> json) =>
      InviteAnswerContent(
        id: json['id'],
        status: json['status'],
        invitedAt: json['invitedAt'],
        answeredAt: json['answeredAt'],
      );

  @override
  String toString() =>
      '{ id: $id, status: $status , invitedAt: $invitedAt, answeredAt: $answeredAt }';
}
