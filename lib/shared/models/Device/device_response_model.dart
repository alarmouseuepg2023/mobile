import 'package:mobile/shared/models/Device/device_list_model.dart';

class DeviceResponse {
  final String message;
  final bool success;
  final DeviceList content;

  DeviceResponse({
    required this.message,
    required this.success,
    required this.content,
  });

  factory DeviceResponse.fromJson(Map<String, dynamic> json) => DeviceResponse(
      content: DeviceList.fromJson(json['content']),
      message: json['message'],
      success: json['success']);

  @override
  String toString() =>
      '{ message: $message, success: $success, content: $content }';
}
