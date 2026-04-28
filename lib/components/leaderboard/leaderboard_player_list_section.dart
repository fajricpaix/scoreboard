import 'package:flutter/material.dart';
import 'package:scoreboard/components/leaderboard/leaderboard_player_tile.dart';

class LeaderboardPlayerListSection extends StatelessWidget {
  final List<Map<String, String>> players;
  final Color accentColor;

  const LeaderboardPlayerListSection({
    super.key,
    required this.players,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < players.length; i++)
          LeaderboardPlayerTile(
            rank: i + 1,
            player: players[i],
            accentColor: accentColor,
          ),
      ],
    );
  }
}
