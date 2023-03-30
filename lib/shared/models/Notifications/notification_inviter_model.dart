// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class NotificationInviter {
  final String name;

  NotificationInviter({
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
    };
  }

  factory NotificationInviter.fromMap(Map<String, dynamic> map) =>
      NotificationInviter(
        name: map['name'] as String,
      );

  String toJson() => jsonEncode(toMap());

  factory NotificationInviter.fromJson(Map<String, dynamic> json) =>
      NotificationInviter(name: json['name']);

  @override
  String toString() => '{ name: $name}';
}
