// ignore_for_file: public_member_api_docs, sort_constructors_first
class StatusAlarmEventModel {
  final String message;
  final String createdAt;

  StatusAlarmEventModel({
    required this.message,
    required this.createdAt,
  });

  factory StatusAlarmEventModel.fromJson(Map<String, dynamic> json) =>
      StatusAlarmEventModel(
          message: json['message'], createdAt: json['createdAt']);
}
