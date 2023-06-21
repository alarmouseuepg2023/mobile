import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/modules/profile/profile_controller.dart';
import 'package:mobile/providers/auth/auth_provider.dart';
import 'package:mobile/providers/notifications/notifications_provider.dart';
import 'package:mobile/shared/themes/app_colors.dart';
import 'package:mobile/shared/themes/app_text_styles.dart';
import 'package:mobile/shared/widgets/label_button/label_button.dart';

import '../../shared/models/Response/server_response_model.dart';
import '../../shared/widgets/toast/toast_widget.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final profileController = ProfileController();
  bool loading = false;

  void handleSignOut() async {
    try {
      setState(() {
        loading = true;
      });
      await profileController.deleteToken();

      if (!mounted) return;

      ref.read(authProvider).clearUser();
      ref.read(notificationsProvider).setNotifications(0);
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      if (e is DioError) {
        ServerResponse response = ServerResponse.fromJson(e.response?.data);
        GlobalToast.show(
            context,
            response.message != ""
                ? response.message
                : "Ocorreu um erro ao sair. Tente novamente.");
      } else {
        GlobalToast.show(context, "Ocorreu um erro ao sair. Tente novamente.");
      }
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void showBottomSheet(context, String feature) {
    showModalBottomSheet(
        enableDrag: false,
        context: context,
        isScrollControlled: true,
        backgroundColor:
            feature == 'STATUS' ? Colors.transparent : Colors.white,
        builder: (BuildContext bc) {
          return WillPopScope(
            onWillPop: () async {
              if (loading) return false;
              return true;
            },
            child: StatefulBuilder(
                builder: (BuildContext context, StateSetter bottomState) {
              if (feature == 'STATUS') {
                return Container(
                  color: Colors.transparent,
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }
              return const SizedBox();
            }),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Center(
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(60)),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 80,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
              child: Text(ref.watch(authProvider).user!.name,
                  style: TextStyles.profileName)),
          Center(
              child: Text(ref.watch(authProvider).user!.email ?? "",
                  style: TextStyles.profileEmail)),
          const SizedBox(
            height: 30,
          ),
          Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, "/change_password");
                },
                child: Ink(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.lock,
                            size: 30, color: AppColors.primary),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Alterar senha",
                          style: TextStyles.profileMenuItem,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, "/delete_account");
                },
                child: Ink(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.delete_forever_outlined,
                            size: 30, color: AppColors.warning),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Excluir conta",
                          style: TextStyles.profileMenuItemDanger,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(child: Container()),
          LabelButtonWidget(
              label: "SAIR",
              reversed: true,
              style: TextStyles.primaryLabel,
              onPressed: () {
                showBottomSheet(context, 'STATUS');
                handleSignOut();
              }),
        ],
      ),
    );
  }
}
