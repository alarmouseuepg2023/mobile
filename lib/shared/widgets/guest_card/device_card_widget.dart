import 'package:flutter/material.dart';
import 'package:mobile/shared/models/Guest/guest_device_model.dart';
import 'package:mobile/shared/themes/app_text_styles.dart';

class GuestCardWidget extends StatefulWidget {
  final GuestDeviceModel guest;
  final VoidCallback onTap;
  const GuestCardWidget({super.key, required this.guest, required this.onTap});

  @override
  State<GuestCardWidget> createState() => _DeviceCardWidgetState();
}

class _DeviceCardWidgetState extends State<GuestCardWidget> {
  String displayName(String name) =>
      "${name.split(" ")[0]} ${name.split(" ")[1]}";

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
                  Text(displayName(widget.guest.name),
                      style: TextStyles.deviceCardName),
                  Text.rich(TextSpan(children: [
                    TextSpan(
                        text: "E-mail: ", style: TextStyles.deviceStatusSub),
                    TextSpan(
                        text: widget.guest.email,
                        style: TextStyles.deviceCardStatus)
                  ])),
                  Text.rich(TextSpan(children: [
                    TextSpan(
                        text: "Convidado: ", style: TextStyles.deviceStatusSub),
                    TextSpan(
                        text: widget.guest.invitedAt.readableDate,
                        style: TextStyles.deviceCardStatus)
                  ])),
                  Text.rich(TextSpan(children: [
                    TextSpan(
                        text: "Convite aceito: ",
                        style: TextStyles.deviceStatusSub),
                    TextSpan(
                        text: widget.guest.answeredAt.readableDate,
                        style: TextStyles.deviceCardStatus)
                  ])),
                ],
              ),
            ],
          )),
    );
  }
}
