import 'package:mobile/shared/models/AlarmEvent/alarm_event_list_model.dart';

class AlarmEventResponse {
  final String message;
  final bool success;
  final AlarmEventList content;

  AlarmEventResponse({
    required this.message,
    required this.success,
    required this.content,
  });

  factory AlarmEventResponse.fromJson(Map<String, dynamic> json) =>
      AlarmEventResponse(
          content: AlarmEventList.fromJson(json['content']),
          message: json['message'],
          success: json['success']);

  @override
  String toString() =>
      '{ message: $message, success: $success, content: $content }';
}
