import 'package:flutter/material.dart';
import 'package:mobile/modules/devices/devices_page.dart';
import 'package:mobile/modules/home/home_controller.dart';
import 'package:mobile/modules/notifications/notifications_page.dart';
import 'package:mobile/modules/profile/profile_page.dart';

import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_text_styles.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _homeController = HomeController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _homeController.currentPage == 0
            ? AppBar(
                title: Text("Bem-vindo, Usuário", style: TextStyles.welcome),
                automaticallyImplyLeading: false,
                flexibleSpace: Container(
                    decoration: const BoxDecoration(color: AppColors.primary)),
              )
            : null,
        body: [
          DevicesPage(key: UniqueKey()),
          NotificationsPage(key: UniqueKey()),
          ProfilePage(
            key: UniqueKey(),
          )
        ][_homeController.currentPage],
        bottomNavigationBar: Container(
            height: 60,
            decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                    top: BorderSide(width: 1, color: AppColors.primary))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Ink(
                    child: InkWell(
                  onTap: () {
                    // if (ref.read(homeProvider).loading) return;
                    _homeController.setPage(0);
                    setState(() {});
                  },
                  child: Icon(
                    Icons.sensors,
                    size: 30,
                    color: _homeController.currentPage == 0
                        ? AppColors.primary
                        : AppColors.text,
                  ),
                )),
                Ink(
                    child: InkWell(
                  onTap: () {
                    // if (ref.read(homeProvider).loading) return;
                    _homeController.setPage(1);
                    setState(() {});
                  },
                  child: Stack(children: [
                    Icon(
                      Icons.notifications,
                      size: 30,
                      color: _homeController.currentPage == 1
                          ? AppColors.primary
                          : AppColors.text,
                    ),
                    Positioned(
                        right: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                              color: AppColors.warning,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          height: 10,
                          width: 10,
                        ))
                  ]),
                )),
                Ink(
                    child: InkWell(
                  onTap: () {
                    // if (ref.read(homeProvider).loading) return;
                    _homeController.setPage(2);
                    setState(() {});
                  },
                  child: Icon(Icons.person,
                      size: 30,
                      color: _homeController.currentPage == 2
                          ? AppColors.primary
                          : AppColors.text),
                )),
              ],
            )),
      ),
    );
  }
}
