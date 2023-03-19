import 'package:flutter/material.dart';
import 'package:mobile/shared/themes/app_colors.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: SizedBox(
        height: double.maxFinite,
        width: double.maxFinite,
        child: Stack(children: [
          const Text("LISTA DE DEVICES"),
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
