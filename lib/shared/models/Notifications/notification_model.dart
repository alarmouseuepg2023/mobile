// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:mobile/shared/models/Notifications/notification_inviter_model.dart';
import 'package:mobile/shared/models/Notifications/notifications_device_model.dart';

class Notification {
  final String id;
  final NotificationDevice device;
  final String invitedAt;
  final NotificationInviter inviter;

  Notification({
    required this.id,
    required this.device,
    required this.invitedAt,
    required this.inviter,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
        id: json['id'],
        device: NotificationDevice.fromJson(json['device']),
        invitedAt: json['invitedAt'],
        inviter: NotificationInviter.fromJson(json['inviter']),
      );

  @override
  String toString() {
    return '{ id: $id, invitedAt: $invitedAt, device: $device, inviter: $inviter}';
  }
}
