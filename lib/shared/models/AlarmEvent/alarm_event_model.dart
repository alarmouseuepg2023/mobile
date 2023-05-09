// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:mobile/shared/models/Device/device_model.dart';

class AlarmEvent {
  final String id;
  final String message;
  final DateTime createdAt;
  final Device device;

  AlarmEvent({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.device,
  });

  factory AlarmEvent.fromJson(Map<String, dynamic> json) => AlarmEvent(
      id: json['id'],
      message: json['message'],
      createdAt: json['createdAt'],
      device: Device.fromJson(json['device']));

  @override
  String toString() {
    return '{ id: $id, message: $message, createdAt: $createdAt, device: $device }';
  }
}
