import 'package:flutter/material.dart';
import 'package:scoreboard/theme/index.dart';

class PlayerScoreCard extends StatelessWidget {
  final String playerName;
  final String scoreText;
  final Color backgroundColor;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const PlayerScoreCard({
    super.key,
    required this.playerName,
    required this.scoreText,
    required this.backgroundColor,
    required this.onDecrease,
    required this.onIncrease,
  });

  Widget _scoreActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 32,
      height: 32,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: textColor,
          padding: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            playerName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            scoreText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _scoreActionButton(icon: Icons.remove, onTap: onDecrease),
              const SizedBox(width: 8),
              _scoreActionButton(icon: Icons.add, onTap: onIncrease),
            ],
          ),
        ],
      ),
    );
  }
}
