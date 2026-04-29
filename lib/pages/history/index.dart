import 'package:flutter/material.dart';
import 'package:scoreboard/components/auth/auth_required.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthRequired(
      title: 'Masuk untuk melihat history',
      message:
          'Riwayat pertandingan hanya tersedia setelah Anda masuk menggunakan akun Google.',
      child: Center(
        child: Text('History Page'),
      ),
    );
  }
}