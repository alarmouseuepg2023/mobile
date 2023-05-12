// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:mobile/shared/models/AlarmEvent/alarm_event_user_model.dart';

class AlarmEvent {
  final String id;
  final String message;
  final String createdAt;
  final String readableDate;
  final AlarmEventUser? user;

  AlarmEvent({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.readableDate,
    this.user,
  });

  factory AlarmEvent.fromJson(Map<String, dynamic> json) => AlarmEvent(
      id: json['id'],
      message: json['message'],
      createdAt: json['createdAt'],
      readableDate: json['readableDate'],
      user: AlarmEventUser.fromJson(json['user']));

  @override
  String toString() {
    return '{ id: $id, message: $message, createdAt: $createdAt, readableDate: $readableDate, user: $user }';
  }
}
