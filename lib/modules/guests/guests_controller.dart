import 'package:dio/dio.dart';
import 'package:mobile/shared/models/Guest/guest_list_response.dart';

import '../../service/index.dart';

class GuestsController {
  Future<GuestListResponse> getGuests(
      String deviceId, int page, int size) async {
    final response = await dio.get('guest/$deviceId?page=$page&size=$size',
        options: Options());

    GuestListResponse data = GuestListResponse.fromJson(response.data);

    return data;
  }
}
