// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class AlarmEventDateFilter {
  final String? start;
  final String? end;

  AlarmEventDateFilter({
    this.start,
    this.end,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'start': start,
      'end': end,
    };
  }

  String toJson() => jsonEncode(toMap());
}
