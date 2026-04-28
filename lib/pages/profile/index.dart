import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: const [
            CircleAvatar(
              radius: 32,
              child: Icon(Icons.person, size: 32),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pengguna Scoreboard',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Kelola akun dan preferensi aplikasi',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          child: Column(
            children: const [
              ListTile(
                leading: Icon(Icons.badge_outlined),
                title: Text('Detail Profil'),
                trailing: Icon(Icons.chevron_right),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.notifications_outlined),
                title: Text('Pengaturan Notifikasi'),
                trailing: Icon(Icons.chevron_right),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Tentang Aplikasi'),
                trailing: Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ],
    );
  }
}