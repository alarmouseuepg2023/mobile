import 'package:dio/dio.dart';
import 'package:mobile/shared/models/Notifications/notifications_response_model.dart';

import '../../service/index.dart';

class NotificationsController {
  Future<NotificationsResponse> getNotifications(int page, int size) async {
    final dio = DioApi().dio;
    final response =
        await dio.get('invite?page=$page&size=$size', options: Options());
    NotificationsResponse data = NotificationsResponse.fromJson(response.data);

    return data;
  }
}
