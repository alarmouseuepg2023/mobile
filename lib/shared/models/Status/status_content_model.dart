// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:mobile/shared/models/Status/status_alarm_event_model.dart';

class StatusContent {
  final String id;
  final String nickname;
  final String status;
  final StatusAlarmEventModel alarmEvent;

  StatusContent({
    required this.id,
    required this.nickname,
    required this.status,
    required this.alarmEvent,
  });

  factory StatusContent.fromJson(Map<String, dynamic> json) => StatusContent(
      id: json['id'],
      nickname: json['nickname'],
      status: json['status'],
      alarmEvent: StatusAlarmEventModel.fromJson(json['alarmEvent']));

  @override
  String toString() {
    return '{ id: $id, nickname: $nickname, status: $status, alarmEvent: $alarmEvent }';
  }
}
