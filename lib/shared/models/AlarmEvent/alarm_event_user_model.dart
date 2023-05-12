// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class AlarmEventUser {
  final String id;
  final String name;

  AlarmEventUser({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
    };
  }

  factory AlarmEventUser.fromJson(Map<String, dynamic> json) =>
      AlarmEventUser(id: json['id'], name: json['name']);

  String toJson() => jsonEncode(toMap());
}
