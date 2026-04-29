import 'package:flutter/material.dart';
import 'package:scoreboard/components/profile/profile_stat_card.dart';

class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -10),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: const [
            Expanded(
              child: ProfileStatCard(
                label: 'Umur',
                value: '33',
                suffix: 'tahun',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ProfileStatCard(
                label: 'Main',
                value: '12',
                suffix: 'kali',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ProfileStatCard(
                label: 'Menang',
                value: '48',
                suffix: 'kali',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
