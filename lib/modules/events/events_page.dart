import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/modules/events/events_controller.dart';
import 'package:mobile/shared/models/AlarmEvent/alarm_event_model.dart';
import 'package:mobile/shared/models/Device/device_model.dart';
import 'package:mobile/shared/widgets/event_card/event_card_widget.dart';

import '../../shared/models/Response/server_response_model.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_text_styles.dart';
import '../../shared/widgets/toast/toast_widget.dart';

class EventsPage extends StatefulWidget {
  final Device device;
  const EventsPage({super.key, required this.device});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final _devicesController = EventsController();
  bool loading = false;
  List<AlarmEvent> events = [];
  int totalItems = 0;
  bool _hasMore = true;
  int _pageNumber = 0;
  final int _size = 10;
  final scrollController = ScrollController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getDevices();
      scrollController.addListener(() {
        if (scrollController.position.maxScrollExtent ==
            scrollController.offset) {
          getDevices();
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

  Future<void> getDevices() async {
    if (!mounted || loading) return;
    try {
      setState(() {
        loading = true;
      });

      final res = await _devicesController.getEvents(
          _pageNumber, _size, widget.device.id);
      if (!mounted) return;
      setState(() {
        events.addAll(res.content.items);
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
                : "Ocorreu um erro ao recuperar os eventos do dispositivo.");
      } else {
        GlobalToast.show(
            context, "Ocorreu um erro ao recuperar os eventos do dispositivo.");
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
      events.clear();
    });

    getDevices();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            shadowColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              "Eventos de ${widget.device.nickname}",
              style: TextStyles.registerWhite,
            ),
            flexibleSpace: Container(
                decoration: const BoxDecoration(color: AppColors.primary)),
            centerTitle: true,
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
                    itemCount: events.length + 1,
                    itemBuilder: (context, index) {
                      if (index < events.length) {
                        final event = events[index];
                        return Column(children: [
                          AlarmEventCardWidget(
                            event: event,
                          ),
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
          )),
    );
  }
}
