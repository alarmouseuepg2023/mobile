import 'package:flutter/material.dart';
import 'package:mobile/modules/devices/devices_page.dart';
import 'package:mobile/modules/home/home_controller.dart';
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
          ProfilePage(key: UniqueKey()),
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
                IconButton(
                    onPressed: () {
                      // if (ref.read(homeProvider).loading) return;
                      _homeController.setPage(0);
                      setState(() {});
                    },
                    icon: Icon(
                      Icons.sensors,
                      size: 30,
                      color: _homeController.currentPage == 0
                          ? AppColors.primary
                          : AppColors.text,
                    )),
                IconButton(
                    onPressed: () {
                      // if (ref.read(homeProvider).loading) return;
                      _homeController.setPage(1);
                      setState(() {});
                    },
                    icon: Icon(Icons.person,
                        size: 30,
                        color: _homeController.currentPage == 1
                            ? AppColors.primary
                            : AppColors.text)),
              ],
            )),
      ),
    );
  }
}
