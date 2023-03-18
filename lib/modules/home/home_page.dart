import 'package:flutter/material.dart';
import 'package:mobile/modules/devices/devices_page.dart';
import 'package:mobile/modules/home/home_controller.dart';

import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_text_styles.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final homeController = HomeController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Bem-vindo, Usuário", style: TextStyles.welcome),
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
              decoration: const BoxDecoration(color: AppColors.primary)),
        ),
        body: [
          DevicesPage(key: UniqueKey()),
        ][homeController.currentPage],
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
                      homeController.setPage(0);
                      setState(() {});
                    },
                    icon: Icon(
                      Icons.calendar_month,
                      color: homeController.currentPage == 0
                          ? AppColors.primary
                          : AppColors.text,
                    )),
                IconButton(
                    onPressed: () {
                      // if (ref.read(homeProvider).loading) return;
                      homeController.setPage(1);
                      setState(() {});
                    },
                    icon: Icon(
                      Icons.personal_injury,
                      color: homeController.currentPage == 1
                          ? AppColors.primary
                          : AppColors.text,
                    )),
                IconButton(
                    onPressed: () {
                      // if (ref.read(homeProvider).loading) return;
                      homeController.setPage(2);
                      setState(() {});
                    },
                    icon: Icon(Icons.person,
                        color: homeController.currentPage == 2
                            ? AppColors.primary
                            : AppColors.text)),
              ],
            )),
      ),
    );
  }
}
