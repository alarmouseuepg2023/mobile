// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:mobile/shared/models/Wifi/wifi_content_model.dart';

class WifiResponse {
  final String message;
  final bool success;
  final WifiContent content;

  WifiResponse({
    required this.message,
    required this.success,
    required this.content,
  });
}
