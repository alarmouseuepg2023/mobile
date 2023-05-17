// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class NotificationDevice {
  final String nickname;

  NotificationDevice({
    required this.nickname,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'nickname': nickname,
    };
  }

  factory NotificationDevice.fromMap(Map<String, dynamic> map) =>
      NotificationDevice(
        nickname: map['nickname'] as String,
      );

  String toJson() => jsonEncode(toMap());

  factory NotificationDevice.fromJson(Map<String, dynamic> json) =>
      NotificationDevice(nickname: json['nickname']);

  @override
  String toString() => '{ nickname: $nickname}';
}
