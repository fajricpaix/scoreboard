import 'package:flutter/material.dart';
import 'package:scoreboard/components/create/models.dart';
import 'package:scoreboard/components/leaderboard/index.dart';

class LeaderboardPage extends StatelessWidget {
  final MatchSetup matchSetup;
  final List<Map<String, String>> players;

  const LeaderboardPage({
    super.key,
    required this.matchSetup,
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    return LeaderboardPageContent(matchSetup: matchSetup, players: players);
  }
}
