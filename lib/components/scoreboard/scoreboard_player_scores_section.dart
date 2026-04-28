import 'package:flutter/material.dart';
import 'package:scoreboard/components/scoreboard/player_score_card.dart';

class ScoreboardPlayerScoresSection extends StatelessWidget {
  final String leftPlayerName;
  final String rightPlayerName;
  final String leftScoreText;
  final String rightScoreText;
  final Color leftPlayerColor;
  final Color rightPlayerColor;
  final VoidCallback? onLeftDecrease;
  final VoidCallback? onLeftIncrease;
  final VoidCallback? onRightDecrease;
  final VoidCallback? onRightIncrease;
  final Widget? leftFooter;
  final Widget? rightFooter;

  const ScoreboardPlayerScoresSection({
    super.key,
    required this.leftPlayerName,
    required this.rightPlayerName,
    required this.leftScoreText,
    required this.rightScoreText,
    required this.leftPlayerColor,
    required this.rightPlayerColor,
    this.onLeftDecrease,
    this.onLeftIncrease,
    this.onRightDecrease,
    this.onRightIncrease,
    this.leftFooter,
    this.rightFooter,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PlayerScoreCard(
            playerName: leftPlayerName,
            scoreText: leftScoreText,
            backgroundColor: leftPlayerColor,
            onDecrease: onLeftDecrease,
            onIncrease: onLeftIncrease,
            footer: leftFooter,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PlayerScoreCard(
            playerName: rightPlayerName,
            scoreText: rightScoreText,
            backgroundColor: rightPlayerColor,
            onDecrease: onRightDecrease,
            onIncrease: onRightIncrease,
            footer: rightFooter,
          ),
        ),
      ],
    );
  }
}
