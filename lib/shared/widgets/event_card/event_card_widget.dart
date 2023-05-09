import 'package:flutter/material.dart';
import 'package:mobile/shared/models/AlarmEvent/alarm_event_model.dart';
import 'package:mobile/shared/themes/app_text_styles.dart';

class AlarmEventCardWidget extends StatefulWidget {
  final AlarmEvent event;
  final VoidCallback onTap;
  const AlarmEventCardWidget(
      {super.key, required this.event, required this.onTap});

  @override
  State<AlarmEventCardWidget> createState() => _AlarmEventCardWidgetState();
}

class _AlarmEventCardWidgetState extends State<AlarmEventCardWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Ink(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 0), // changes position of shadow
              ),
            ],
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.event.id, style: TextStyles.deviceCardName),
                  Text.rich(TextSpan(children: [
                    TextSpan(
                        text: "Estado: ", style: TextStyles.deviceStatusSub),
                    TextSpan(
                        text: widget.event.message,
                        style: TextStyles.deviceCardStatus)
                  ])),
                  Text(widget.event.device.nickname,
                      style: TextStyles.deviceCardOwnership),
                ],
              ),
            ],
          )),
    );
  }
}
