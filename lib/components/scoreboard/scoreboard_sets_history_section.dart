import 'package:flutter/material.dart';
import 'package:scoreboard/components/scoreboard/models.dart';
import 'package:scoreboard/components/scoreboard/score_history_section.dart';
import 'package:scoreboard/components/scoreboard/set_selector.dart';

class ScoreboardSetsHistorySection extends StatelessWidget {
  final bool usesSetTracking;
  final int setCount;
  final int selectedSet;
  final Map<int, bool> setWinners;
  final Color leftPlayerColor;
  final Color rightPlayerColor;
  final Color accentColor;
  final VoidCallback onAddSet;
  final ValueChanged<int> onSelectSet;
  final bool hasSetTimer;
  final String setDurationText;
  final String leftPlayerName;
  final String rightPlayerName;
  final List<ScoreHistoryItem> items;
  final String Function(int) scoreTextBuilder;

  const ScoreboardSetsHistorySection({
    super.key,
    required this.usesSetTracking,
    required this.setCount,
    required this.selectedSet,
    required this.setWinners,
    required this.leftPlayerColor,
    required this.rightPlayerColor,
    required this.accentColor,
    required this.onAddSet,
    required this.onSelectSet,
    required this.hasSetTimer,
    required this.setDurationText,
    required this.leftPlayerName,
    required this.rightPlayerName,
    required this.items,
    required this.scoreTextBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (usesSetTracking) ...[
          SetSelector(
            setCount: setCount,
            selectedSet: selectedSet,
            setWinners: setWinners,
            leftPlayerColor: leftPlayerColor,
            rightPlayerColor: rightPlayerColor,
            accentColor: accentColor,
            onAddSet: onAddSet,
            onSelectSet: onSelectSet,
          ),
          const SizedBox(height: 14),
        ],
        ScoreHistorySection(
          isSetMode: usesSetTracking,
          selectedSet: selectedSet,
          hasSetTimer: hasSetTimer,
          setDurationText: setDurationText,
          accentColor: accentColor,
          leftPlayerName: leftPlayerName,
          rightPlayerName: rightPlayerName,
          leftPlayerColor: leftPlayerColor,
          rightPlayerColor: rightPlayerColor,
          items: items,
          scoreTextBuilder: scoreTextBuilder,
        ),
      ],
    );
  }
}
