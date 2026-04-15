import 'package:flutter/material.dart';

class LeaderboardSummaryCard extends StatelessWidget {
  final String matchName;
  final String sportName;
  final String gameType;
  final String rankModeLabel;
  final int playerCount;
  final List<Color> gradientColors;

  const LeaderboardSummaryCard({
    super.key,
    required this.matchName,
    required this.sportName,
    required this.gameType,
    required this.rankModeLabel,
    required this.playerCount,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            matchName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$sportName • $gameType',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Urutan rank: $rankModeLabel tertinggi',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            'Jumlah Pemain: $playerCount pemain',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
