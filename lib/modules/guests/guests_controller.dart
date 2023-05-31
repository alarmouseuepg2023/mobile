import 'package:dio/dio.dart';
import 'package:mobile/shared/models/Guest/guest_list_response.dart';
import 'package:mobile/shared/models/Guest/guest_revoke_model.dart';
import 'package:mobile/shared/models/Response/server_response_model.dart';

import '../../service/index.dart';

class GuestsController {
  Future<GuestListResponse> getGuests(
      String deviceId, int page, int size) async {
    final dio = DioApi().dio;
    final response = await dio.get('guest/$deviceId?page=$page&size=$size',
        options: Options());

    GuestListResponse data = GuestListResponse.fromJson(response.data);

    return data;
  }

  Future<ServerResponse> revokeGuest(String deviceId, String guestId) async {
    final dio = DioApi().dio;
    final reqData = GuestRevoke(guestId: guestId);

    final response = await dio.post('guest/revoke/$deviceId',
        data: reqData.toJson(), options: Options());

    ServerResponse data = ServerResponse.fromJson(response.data);

    return data;
  }
}
