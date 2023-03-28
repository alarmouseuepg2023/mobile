import 'package:flutter/material.dart';
import 'package:mobile/shared/models/Device/device_model.dart';

import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_text_styles.dart';

class EventsPage extends StatefulWidget {
  final Device device;
  const EventsPage({super.key, required this.device});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          shadowColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.primary),
          title: Text(
            "Eventos de ${widget.device.nickname}",
            style: TextStyles.register,
          ),
          centerTitle: true,
        ),
        body: const Text('EVENTS'),
      ),
    );
  }
}
