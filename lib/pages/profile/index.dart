import 'package:flutter/material.dart';
import 'package:scoreboard/components/profile/profile_header.dart';
import 'package:scoreboard/components/profile/profile_stats_row.dart';
import 'package:scoreboard/components/profile/profile_menu.dart';
import 'package:scoreboard/components/profile/profile_logout_button.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ProfileHeader(),
            const ProfileStatsRow(),
            const ProfileMenu(),
            const SizedBox(height: 20),
            const ProfileLogoutButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

