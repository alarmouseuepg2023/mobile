import 'package:dio/dio.dart';
import 'package:mobile/shared/models/AlarmEvent/alarm_event_response_model.dart';

import '../../service/index.dart';

class EventsController {
  Future<AlarmEventResponse> getEvents(
      int page, int size, String deviceId) async {
    final response = await dio
        .get('alarmEvents/$deviceId?page=$page&size=$size', options: Options());

    AlarmEventResponse data = AlarmEventResponse.fromJson(response.data);

    return data;
  }
}
