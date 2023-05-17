// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class StatusRequest {
  final String? status;
  final String? password;

  StatusRequest({
    this.status,
    this.password,
  });

  StatusRequest copyWith({
    String? status,
    String? password,
  }) {
    return StatusRequest(
      status: status ?? this.status,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'status': status,
      'password': password,
    };
  }

  String toJson() => jsonEncode(toMap());
}
