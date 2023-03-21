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
              child: Text("Henrique Hartmann", style: TextStyles.profileName)),
          const SizedBox(
            height: 30,
          ),
          Column(),
          Expanded(child: Container()),
          LabelButtonWidget(
              label: "SAIR",
              reversed: true,
              style: TextStyles.primaryLabel,
              onPressed: () {
                ref.read(authProvider).clearUser();
                Navigator.of(context).pushReplacementNamed('/login');
              }),
        ],
      ),
    );
  }
}
