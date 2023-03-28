import 'package:flutter/material.dart';
import 'package:mobile/shared/models/Device/device_model.dart';

class EventsPage extends StatefulWidget {
  final Device device;
  const EventsPage({super.key, required this.device});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
