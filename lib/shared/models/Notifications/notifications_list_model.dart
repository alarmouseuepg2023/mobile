// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:mobile/shared/models/Notifications/notification_model.dart';

class NotificationsList {
  final int totalItems;
  final List<Notification> items;

  NotificationsList({
    required this.totalItems,
    required this.items,
  });

  factory NotificationsList.fromJson(Map<String, dynamic> json) =>
      NotificationsList(
          totalItems: json['totalItems'],
          items: List<dynamic>.from(json['items'])
              .map((item) => Notification.fromJson(item))
              .toList());

  @override
  String toString() => '{ items: $items, totalItems: $totalItems }';
}
