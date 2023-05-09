// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:mobile/shared/models/AlarmEvent/alarm_event_model.dart';

class AlarmEventList {
  final int totalItems;
  final List<AlarmEvent> items;

  AlarmEventList({
    required this.totalItems,
    required this.items,
  });

  factory AlarmEventList.fromJson(Map<String, dynamic> json) => AlarmEventList(
      totalItems: json['totalItems'],
      items: List<dynamic>.from(json['items'])
          .map((item) => AlarmEvent.fromJson(item))
          .toList());

  @override
  String toString() => '{ items: $items, totalItems: $totalItems }';
}
