// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:mobile/shared/models/AlarmEvent/alarm_event_date_filter_model.dart';

class AlarmEventListRequest {
  final String? status;
  final AlarmEventDateFilter? date;

  AlarmEventListRequest({
    this.status,
    this.date,
  });

  AlarmEventListRequest copyWith({
    String? status,
    AlarmEventDateFilter? date,
  }) {
    return AlarmEventListRequest(
      status: status ?? this.status,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'status': status,
      'date': date,
    };
  }

  factory AlarmEventListRequest.fromMap(Map<String, dynamic> map) {
    return AlarmEventListRequest(
      status: map['status'] != null ? map['status'] as String : null,
      date: map['date'] != null ? map['date'] as AlarmEventDateFilter : null,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory AlarmEventListRequest.fromJson(String source) =>
      AlarmEventListRequest.fromMap(jsonEncode(source) as Map<String, dynamic>);
}
