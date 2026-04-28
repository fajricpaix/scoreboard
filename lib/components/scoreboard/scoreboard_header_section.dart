import 'package:flutter/material.dart';
import 'package:scoreboard/components/scoreboard/match_summary_card.dart';
import 'package:scoreboard/components/scoreboard/set_score_summary.dart';

class ScoreboardHeaderSection extends StatelessWidget {
  final String title;
  final String durationText;
  final List<Color> gradientColors;
  final bool usesSetTracking;
  final int leftSetWins;
  final int rightSetWins;
  final Color accentColor;

  const ScoreboardHeaderSection({
    super.key,
    required this.title,
    required this.durationText,
    required this.gradientColors,
    required this.usesSetTracking,
    required this.leftSetWins,
    required this.rightSetWins,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MatchSummaryCard(
          title: title,
          durationText: durationText,
          gradientColors: gradientColors,
        ),
        if (usesSetTracking) ...[
          const SizedBox(height: 12),
          SetScoreSummary(
            leftSetWins: leftSetWins,
            rightSetWins: rightSetWins,
            cardColor: accentColor,
          ),
        ],
      ],
    );
  }
}
