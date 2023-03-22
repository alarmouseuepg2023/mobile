import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/auth/auth_provider.dart';
import 'package:mobile/shared/themes/app_colors.dart';
import 'package:mobile/shared/themes/app_text_styles.dart';
import 'package:mobile/shared/widgets/label_button/label_button.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  void handleSignOut() {
    ref.read(authProvider).clearUser();
    Navigator.pushReplacementNamed(context, '/login');
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
              child: Text(
                  ref.watch(authProvider).user!.email ?? "matusas@email.com",
                  style: TextStyles.profileEmail)),
          const SizedBox(
            height: 30,
          ),
          Column(
            children: [
              InkWell(
                onTap: () {},
                child: Ink(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications,
                            size: 30, color: AppColors.primary),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Notificações",
                          style: TextStyles.profileMenuItem,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {},
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
            ],
          ),
          Expanded(child: Container()),
          LabelButtonWidget(
              label: "SAIR",
              reversed: true,
              style: TextStyles.primaryLabel,
              onPressed: handleSignOut),
        ],
      ),
    );
  }
}
