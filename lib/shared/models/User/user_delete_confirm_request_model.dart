// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserDeleteConfirmRequest {
  final String? pin;

  UserDeleteConfirmRequest({this.pin});

  UserDeleteConfirmRequest copyWith({
    String? pin,
  }) {
    return UserDeleteConfirmRequest(
      pin: pin ?? this.pin,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pin': pin,
    };
  }

  String toJson() => jsonEncode(toMap());
}
