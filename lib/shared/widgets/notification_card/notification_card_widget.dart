import 'package:flutter/material.dart';
import 'package:mobile/shared/models/Notifications/notification_model.dart';
import 'package:mobile/shared/themes/app_text_styles.dart';

class NotificationCardWidget extends StatefulWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  const NotificationCardWidget(
      {super.key, required this.notification, required this.onTap});

  @override
  State<NotificationCardWidget> createState() => _DeviceCardWidgetState();
}

class _DeviceCardWidgetState extends State<NotificationCardWidget> {
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
                  Text(widget.notification.device.nickname,
                      style: TextStyles.deviceCardName),
                  Text.rich(TextSpan(children: [
                    TextSpan(
                        text: "Proprietário: ",
                        style: TextStyles.deviceStatusSub),
                    TextSpan(
                        text:
                            "${widget.notification.inviter.name.split(" ")[0]} ${widget.notification.inviter.name.split(" ")[1]}",
                        style: TextStyles.deviceCardStatus)
                  ])),
                  Text(widget.notification.invitedAt,
                      style: TextStyles.deviceCardOwnership),
                ],
              ),
            ],
          )),
    );
  }
}
