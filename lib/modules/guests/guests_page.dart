import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/modules/guests/guests_controller.dart';
import 'package:mobile/shared/models/Device/device_model.dart';
import 'package:mobile/shared/models/Guest/guest_device_model.dart';
import 'package:mobile/shared/themes/app_text_styles.dart';

import '../../shared/models/Response/server_response_model.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/widgets/toast/toast_widget.dart';

class GuestsPage extends StatefulWidget {
  final Device device;
  const GuestsPage({super.key, required this.device});

  @override
  State<GuestsPage> createState() => _GuestsPageState();
}

class _GuestsPageState extends State<GuestsPage> {
  final _guestsController = GuestsController();
  bool loading = false;
  List<GuestDeviceModel> guests = [];
  int totalItems = 0;
  bool _hasMore = true;
  int _pageNumber = 0;
  final int _size = 10;
  final scrollController = ScrollController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getGuests();
      scrollController.addListener(() {
        if (scrollController.position.maxScrollExtent ==
            scrollController.offset) {
          getGuests();
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> getGuests() async {
    if (!mounted || loading) return;
    try {
      setState(() {
        loading = true;
      });

      final res = await _guestsController.getGuests(
          widget.device.id, _pageNumber, _size);
      if (!mounted) return;
      setState(() {
        guests.addAll(res.content.items);
        if (res.content.items.length < _size) {
          _hasMore = false;
        }
        totalItems = res.content.totalItems;
        _pageNumber++;
      });
    } catch (e) {
      if (e is DioError) {
        ServerResponse response = ServerResponse.fromJson(e.response?.data);

        GlobalToast.show(
            context,
            response.message != ""
                ? response.message
                : "Ocorreu um erro ao recuperar os convidados deste dispositivo.");
      } else {
        GlobalToast.show(context,
            "Ocorreu um erro ao recuperar os convidados deste dispositivo.");
      }
    } finally {
      // ignore: control_flow_in_finally
      if (!mounted) return;
      setState(() {
        loading = false;
      });
    }
  }

  Future refresh() async {
    setState(() {
      loading = false;
      _hasMore = true;
      _pageNumber = 0;
      guests.clear();
    });

    getGuests();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Convidados de ${widget.device.nickname}",
              style: TextStyles.welcome),
          flexibleSpace: Container(
              decoration: const BoxDecoration(color: AppColors.primary)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(children: [
            Expanded(
              flex: 1,
              child: RefreshIndicator(
                onRefresh: refresh,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: scrollController,
                  itemCount: guests.length + 1,
                  itemBuilder: (context, index) {
                    if (index < guests.length) {
                      final guest = guests[index];
                      return Column(children: [
                        Text(guest.name),
                        const SizedBox(
                          height: 20,
                        )
                      ]);
                    } else {
                      return _hasMore
                          ? const Center(
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : const Center();
                    }
                  },
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
