import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile/shared/models/AlarmEvent/alarm_event_date_filter_model.dart';
import 'package:mobile/shared/models/AlarmEvent/alarm_event_list_request_model.dart';
import 'package:mobile/shared/models/AlarmEvent/alarm_event_response_model.dart';

import '../../service/index.dart';

class EventsController {
  final formKey = GlobalKey<FormState>();
  AlarmEventListRequest model = AlarmEventListRequest(
      date: AlarmEventDateFilter(start: '', end: ''), status: '');

  void onChange({String? status, AlarmEventDateFilter? date}) {
    model = model.copyWith(status: status, date: date);
  }

  Future<AlarmEventResponse?> getEvents(
      int page, int size, String deviceId) async {
    final dio = DioApi().dio;
    final formData = {
      'status': model.status == '0' ? null : model.status,
      'date': {'start': model.date?.start, 'end': model.date?.end}
    };

    final response = await dio.post(
        'alarmEvents/$deviceId?page=$page&size=$size',
        data: formData,
        options: Options());

    AlarmEventResponse data = AlarmEventResponse.fromJson(response.data);

    return data;
  }
}
