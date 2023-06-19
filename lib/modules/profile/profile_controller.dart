import 'package:dio/dio.dart';

import '../../service/index.dart';
import '../../shared/models/PushNotification/push_notification_response_model.dart';

class ProfileController {
  Future<PushNotificationResponse?> sendToken() async {
    final dio = DioApi().dio;
    final formData = {'token': "dfujaiendme"};

    final response = await dio.patch('pushNotifications',
        data: formData, options: Options());
    PushNotificationResponse data =
        PushNotificationResponse.fromJson(response.data);
    return data;
  }
}
