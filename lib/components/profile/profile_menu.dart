import 'package:flutter/material.dart';
import 'package:scoreboard/theme/index.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.blueGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        children: const [
          ListTile(
            leading: Icon(Icons.badge_outlined, color: textColor),
            title: Text('Detail Profil', style: TextStyle(color: textColor)),
            trailing: Icon(Icons.chevron_right, color: textColor),
          ),
          Divider(height: 1, color: Colors.white),
          ListTile(
            leading: Icon(Icons.info_outline, color: textColor),
            title: Text('Tentang Aplikasi', style: TextStyle(color: textColor)),
            trailing: Icon(Icons.chevron_right, color: textColor),
          ),
        ],
      ),
    );
  }
}
