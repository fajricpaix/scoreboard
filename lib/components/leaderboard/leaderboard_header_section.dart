import 'package:flutter/material.dart';
import 'package:scoreboard/components/leaderboard/leaderboard_summary_card.dart';

class LeaderboardHeaderSection extends StatelessWidget {
  final String matchName;
  final String sportName;
  final String gameType;
  final String rankModeLabel;
  final int playerCount;
  final List<Color> gradientColors;

  const LeaderboardHeaderSection({
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
    return LeaderboardSummaryCard(
      matchName: matchName,
      sportName: sportName,
      gameType: gameType,
      rankModeLabel: rankModeLabel,
      playerCount: playerCount,
      gradientColors: gradientColors,
    );
  }
}
