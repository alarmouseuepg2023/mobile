import 'package:flutter/material.dart';
import 'package:mobile/shared/models/AlarmEvent/alarm_event_model.dart';
import 'package:mobile/shared/themes/app_colors.dart';
import 'package:mobile/shared/themes/app_text_styles.dart';

class AlarmEventCardWidget extends StatefulWidget {
  final AlarmEvent event;
  const AlarmEventCardWidget({super.key, required this.event});

  @override
  State<AlarmEventCardWidget> createState() => _AlarmEventCardWidgetState();
}

class _AlarmEventCardWidgetState extends State<AlarmEventCardWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          _expanded = !_expanded;
        });
      },
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
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _expanded
                        ? Icons.expand_less_outlined
                        : Icons.expand_more_outlined,
                    size: 40,
                    color: AppColors.textFaded,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.event.status,
                          style: TextStyles.deviceCardName),
                      Text.rich(TextSpan(children: [
                        TextSpan(
                            text: widget.event.readableDate,
                            style: TextStyles.deviceStatusSub),
                      ])),
                    ],
                  ),
                ],
              ),
              _expanded
                  ? Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.event.message,
                            style: TextStyles.deviceCardOwnership,
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text.rich(TextSpan(children: [
                            TextSpan(
                                text: "Data: ",
                                style: TextStyles.deviceCardStatus),
                            TextSpan(
                                text: widget.event.createdAt,
                                style: TextStyles.deviceStatusSub),
                          ])),
                          const SizedBox(
                            height: 20,
                          ),
                          Text.rich(
                            TextSpan(children: [
                              TextSpan(
                                  text: "Acionado por: ",
                                  style: TextStyles.deviceCardStatus),
                              TextSpan(
                                  text: widget.event.user != null
                                      ? widget.event.user!.name
                                      : "Dispositivo",
                                  style: TextStyles.deviceStatusSub),
                            ]),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox()
            ],
          )),
    );
  }
}
