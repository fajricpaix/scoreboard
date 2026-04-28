import 'package:flutter/material.dart';
import 'package:scoreboard/components/create/models.dart';
import 'package:scoreboard/components/scoreboard/scoreboard_page_content.dart';

export 'package:scoreboard/components/scoreboard/models.dart' show MatchResult;

class ScoreboardPage extends StatelessWidget {
  final MatchSetup matchSetup;
  final String leftPlayerName;
  final String rightPlayerName;
  final DateTime startedAt;
  final List<String> leftPlayers;
  final List<String> rightPlayers;

  const ScoreboardPage({
    super.key,
    required this.matchSetup,
    required this.leftPlayerName,
    required this.rightPlayerName,
    required this.startedAt,
    required this.leftPlayers,
    required this.rightPlayers,
  });

  @override
  Widget build(BuildContext context) {
    return ScoreboardPageContent(
      matchSetup: matchSetup,
      leftPlayerName: leftPlayerName,
      rightPlayerName: rightPlayerName,
      startedAt: startedAt,
      leftPlayers: leftPlayers,
      rightPlayers: rightPlayers,
    );
  }
}
