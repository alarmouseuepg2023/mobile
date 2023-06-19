import 'package:dio/dio.dart';
import 'package:mobile/shared/models/Response/server_response_model.dart';

import '../../service/index.dart';

class ProfileController {
  Future<ServerResponse?> deleteToken() async {
    final dio = DioApi().dio;

    final response = await dio.delete('pushNotifications', options: Options());
    ServerResponse data = ServerResponse.fromJson(response.data);
    return data;
  }
}
