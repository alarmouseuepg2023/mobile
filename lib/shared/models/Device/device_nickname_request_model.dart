// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class DeviceNicknameRequest {
  final String? nickname;

  DeviceNicknameRequest({
    this.nickname,
  });

  DeviceNicknameRequest copyWith({
    String? nickname,
  }) {
    return DeviceNicknameRequest(
      nickname: nickname ?? this.nickname,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'nickname': nickname,
    };
  }

  factory DeviceNicknameRequest.fromMap(Map<String, dynamic> map) {
    return DeviceNicknameRequest(
      nickname: map['nickname'] != null ? map['nickname'] as String : null,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory DeviceNicknameRequest.fromJson(String source) =>
      DeviceNicknameRequest.fromMap(jsonEncode(source) as Map<String, dynamic>);
}
