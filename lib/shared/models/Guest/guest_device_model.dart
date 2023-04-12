// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:mobile/shared/models/ReadableDate/readable_date_model.dart';

class GuestDeviceModel {
  final String id;
  final String name;
  final String email;
  final ReadableDate answeredAt;
  final ReadableDate invitedAt;

  GuestDeviceModel({
    required this.id,
    required this.name,
    required this.email,
    required this.answeredAt,
    required this.invitedAt,
  });

  factory GuestDeviceModel.fromJson(Map<String, dynamic> json) =>
      GuestDeviceModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        answeredAt: ReadableDate.fromJson(json['answeredAt']),
        invitedAt: ReadableDate.fromJson(json['invitedAt']),
      );
}
