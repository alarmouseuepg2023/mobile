import 'package:mobile/shared/models/Status/status_content_model.dart';

class StatusResponseModel {
  final String message;
  final bool success;
  final StatusContent content;

  StatusResponseModel({
    required this.message,
    required this.success,
    required this.content,
  });

  factory StatusResponseModel.fromJson(Map<String, dynamic> json) =>
      StatusResponseModel(
          content: StatusContent.fromJson(json['content']),
          message: json['message'],
          success: json['success']);

  @override
  String toString() =>
      '{ message: $message, success: $success, content: $content }';
}
