import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/modules/devices/devices_controller.dart';
import 'package:mobile/shared/models/Response/server_response_model.dart';
import 'package:mobile/shared/themes/app_colors.dart';
import 'package:mobile/shared/widgets/device_card/device_card_widget.dart';
import 'package:mobile/shared/widgets/toast/toast_widget.dart';

import '../../shared/models/Device/device_model.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  final _devicesController = DevicesController();
  bool loading = false;
  List<Device> devices = [];
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
    print('sim $mounted');
    try {
      setState(() {
        loading = true;
      });

      final res = await _devicesController.getDevices(_pageNumber, _size);
      if (!mounted) return;
      setState(() {
        devices.addAll(res.content.items);
        if (res.content.items.length < _size) {
          _hasMore = false;
        }
        totalItems = res.content.totalItems;
        _pageNumber++;
      });
    } catch (e) {
      print(e);
      if (e is DioError) {
        print(e.response);
        if (e.response != null && e.response!.statusCode! >= 500) {
          GlobalToast.show(context, "Ocorreu um erro ao consultar o servidor.");
          return;
        }
        ServerResponse response = ServerResponse.fromJson(e.response?.data);

        GlobalToast.show(
            context,
            response.message != ""
                ? response.message
                : "Ocorreu um erro ao recuperar os dispositivos.");
      } else {
        GlobalToast.show(
            context, "Ocorreu um erro ao recuperar os dispositivos.");
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
      devices.clear();
    });

    getDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(children: [
        Expanded(
          flex: 1,
          child: RefreshIndicator(
            onRefresh: refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: scrollController,
              itemCount: devices.length + 1,
              itemBuilder: (context, index) {
                if (index < devices.length) {
                  final device = devices[index];
                  return Column(children: [
                    DeviceCardWidget(
                      device: device,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          "/device",
                          arguments: device,
                        );
                      },
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
        Align(
          alignment: Alignment.bottomRight,
          child: FloatingActionButton(
            onPressed: loading
                ? null
                : () {
                    Navigator.pushNamed(context, "/add_device");
                  },
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
      ]),
    );
  }
}
