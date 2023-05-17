// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:mobile/shared/models/Guest/guest_device_model.dart';

class GuestList {
  final int totalItems;
  final List<GuestDeviceModel> items;

  GuestList({
    required this.totalItems,
    required this.items,
  });

  factory GuestList.fromJson(Map<String, dynamic> json) => GuestList(
      totalItems: json['totalItems'],
      items: List<dynamic>.from(json['items'])
          .map((item) => GuestDeviceModel.fromJson(item))
          .toList());

  @override
  String toString() => '{ items: $items, totalItems: $totalItems }';
}
