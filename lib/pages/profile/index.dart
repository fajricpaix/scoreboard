import 'package:flutter/material.dart';
import 'package:scoreboard/components/auth/auth_required.dart';
import 'package:scoreboard/components/profile/profile_header.dart';
import 'package:scoreboard/components/profile/profile_stats_row.dart';
import 'package:scoreboard/components/profile/profile_menu.dart';
import 'package:scoreboard/components/profile/profile_logout_button.dart';
import 'package:scoreboard/services/auth_service.dart';
import 'package:scoreboard/theme/index.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _confirmSignOut(BuildContext context) async {
    final bool? shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          surfaceTintColor: backgroundColor,
          title: const Text(
            'Keluar dari akun?',
            style: TextStyle(color: textColor),
          ),
          content: const Text(
            'Anda yakin ingin logout dari akun Google ini?',
            style: TextStyle(color: textColor),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Batal', style: TextStyle(color: textColor)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: error,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldSignOut == true) {
      await AuthService.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthRequired(
      title: 'Masuk untuk membuka profil',
      message:
          'Silakan masuk menggunakan Google agar data profil dan pengaturan akun bisa digunakan.',
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const ProfileHeader(),
              const ProfileStatsRow(),
              const ProfileMenu(),
              const SizedBox(height: 40),
              ProfileLogoutButton(
                onPressed: () async {
                  await _confirmSignOut(context);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

