// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:mobile/shared/models/Device/device_model.dart';

class DeviceList {
  final int totalItems;
  final List<Device> items;

  DeviceList({
    required this.totalItems,
    required this.items,
  });

  factory DeviceList.fromJson(Map<String, dynamic> json) => DeviceList(
      totalItems: json['totalItems'],
      items: List<dynamic>.from(json['items'])
          .map((item) => Device.fromJson(item))
          .toList());

  @override
  String toString() => '{ items: $items, totalItems: $totalItems }';
}
