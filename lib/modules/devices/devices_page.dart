import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/modules/devices/devices_controller.dart';
import 'package:mobile/shared/models/Response/response_model.dart';
import 'package:mobile/shared/themes/app_colors.dart';
import 'package:mobile/shared/widgets/device_card/device_card_widget.dart';

import '../../shared/models/Device/device_model.dart';
import '../../shared/widgets/snackbar/snackbar_widget.dart';

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
    try {
      if (!mounted || loading) return;
      setState(() {
        loading = true;
      });
      // final hasUser = await ref.read(authProvider).getUserData();
      // if (hasUser) {
      //   final accessToken = ref.read(authProvider).accessToken;
      //   dio.options.headers[HttpHeaders.authorizationHeader] =
      //       "bearer $accessToken";
      // }
      final res = await _devicesController.getDevices(_pageNumber, _size);
      setState(() {
        devices.addAll(res.content.items);
        if (res.content.items.length < _size) {
          _hasMore = false;
        }
        totalItems = res.content.totalItems;
        _pageNumber++;
      });
    } catch (e) {
      if (e is DioError) {
        ServerResponse response = ServerResponse.fromJson(e.response?.data);

        GlobalSnackBar.show(
            context,
            response.message != ""
                ? response.message
                : "Ocorreu um erro ao recuperar os dispositivos.");
      } else {
        GlobalSnackBar.show(
            context, "Ocorreu um erro ao recuperar os dispositivos.");
      }
    } finally {
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
      child: SizedBox(
        height: double.maxFinite,
        width: double.maxFinite,
        child: Stack(children: [
          RefreshIndicator(
            onRefresh: refresh,
            child: ListView.builder(
              controller: scrollController,
              itemCount: devices.length + 1,
              itemBuilder: (context, index) {
                if (index < devices.length) {
                  final device = devices[index];
                  return DeviceCardWidget(device: device);
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
          Positioned(
            bottom: 10,
            right: 10,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(30),
              splashColor: AppColors.darker,
              child: Ink(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(30)),
                  child: const Icon(Icons.add, color: Colors.white, size: 30)),
            ),
          )
        ]),
      ),
    );
  }
}
