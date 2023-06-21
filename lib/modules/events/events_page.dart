import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/modules/events/events_controller.dart';
import 'package:mobile/shared/models/AlarmEvent/alarm_event_date_filter_model.dart';
import 'package:mobile/shared/models/AlarmEvent/alarm_event_model.dart';
import 'package:mobile/shared/models/Device/device_model.dart';
import 'package:mobile/shared/models/Status/status_options_model.dart';
import 'package:mobile/shared/widgets/date_picker/date_picker_widget.dart';
import 'package:mobile/shared/widgets/dropdown_menu/dropdown_menu_widget.dart';
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
  final _eventsController = EventsController();
  bool loading = false;
  List<AlarmEvent> events = [];
  int totalItems = 0;
  bool _hasMore = true;
  int _pageNumber = 0;
  final int _size = 10;
  final scrollController = ScrollController();
  List<StatusOption> statusOptions = [
    StatusOption(name: "Todos", value: '0'),
    StatusOption(name: "Bloqueado", value: '1'),
    StatusOption(name: "Desbloqueado", value: '2'),
    StatusOption(name: "Disparado", value: '3'),
    StatusOption(name: "Aguardando confirmação", value: '4'),
  ];
  TextEditingController initialDate = TextEditingController();
  TextEditingController finalDate = TextEditingController();
  final dropdownState = GlobalKey<FormFieldState>();
  StatusOption currentStatus = StatusOption(name: 'Todos', value: '0');

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getEvents(false);
      scrollController.addListener(() {
        if (scrollController.position.maxScrollExtent ==
            scrollController.offset) {
          getEvents(false);
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

  Future<void> getEvents(bool? filter) async {
    if (!mounted || loading) return;
    try {
      setState(() {
        loading = true;
      });

      final res = await _eventsController.getEvents(
          _pageNumber, _size, widget.device.id);
      if (!mounted) return;

      if (res != null) {
        setState(() {
          if (filter != null && filter == true) {
            events = res.content.items;
          } else {
            events.addAll(res.content.items);
          }
          if (res.content.items.length < _size) {
            _hasMore = false;
          }
          totalItems = res.content.totalItems;
          _pageNumber++;
        });
      }
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
    _eventsController.onChange(
        date: AlarmEventDateFilter(start: '', end: ''), status: '');
    initialDate.clear();
    finalDate.clear();
    setState(() {
      loading = false;
      _hasMore = true;
      _pageNumber = 0;
      currentStatus = StatusOption(name: 'Todos', value: '0');
      events.clear();
    });

    getEvents(false);
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(
              child: Text(
                "Filtro de eventos",
                style: TextStyles.addDeviceIntroBold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: _eventsController.formKey,
                  child: Column(
                    children: [
                      DropdownMenuWidget(
                          value: currentStatus.value,
                          label: "Estado",
                          options: statusOptions,
                          onChanged: (value) {
                            setState(() {
                              currentStatus = statusOptions.firstWhere(
                                  (element) => element.value == value);
                            });
                            _eventsController.onChange(status: value);
                          }),
                      const SizedBox(
                        height: 20,
                      ),
                      DatePickerWidget(
                          controller: initialDate,
                          label: "Data inicial",
                          onChanged: ((value) {
                            String finalDateReverse =
                                finalDate.text.split('/').reversed.join('-');
                            _eventsController.onChange(
                                date: AlarmEventDateFilter(
                                    start: value, end: finalDateReverse));
                          })),
                      const SizedBox(
                        height: 20,
                      ),
                      DatePickerWidget(
                          controller: finalDate,
                          label: "Data final",
                          onChanged: ((value) {
                            String initialDateReverse =
                                initialDate.text.split('/').reversed.join('-');
                            _eventsController.onChange(
                                date: AlarmEventDateFilter(
                                    end: value, start: initialDateReverse));
                          }))
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              InkWell(
                onTap: () {
                  setState(() {
                    loading = false;
                    _hasMore = true;
                    _pageNumber = 0;
                    events.clear();
                  });
                  getEvents(true);
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    "Filtrar",
                    style: TextStyles.deviceCardStatus,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  finalDate.text = '';
                  initialDate.text = '';
                  _eventsController.onChange(
                      status: '',
                      date: AlarmEventDateFilter(end: '', start: ''));
                  refresh();
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Limpar",
                    style: TextStyles.cancelDialog,
                  ),
                ),
              ),
            ],
          );
        });
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
            actions: [
              IconButton(
                onPressed: () {
                  showAlertDialog(context);
                },
                icon: const Icon(Icons.filter_alt),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              )
            ],
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
                            : Center(
                                child: Text("Não há eventos para mostrar",
                                    style: TextStyles.emptyList),
                              );
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
