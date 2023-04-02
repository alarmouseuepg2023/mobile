import 'package:dio/dio.dart';

import '../../service/index.dart';
import '../../shared/models/Device/device_response_model.dart';

class DevicesController {
  Future<DeviceResponse> getDevices(int page, int size) async {
    print('get devices');
    final response =
        await dio.get('device?page=$page&size=$size', options: Options());

    DeviceResponse data = DeviceResponse.fromJson(response.data);

    return data;
  }
}
