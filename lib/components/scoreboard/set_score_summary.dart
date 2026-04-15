import 'package:flutter/material.dart';
import 'package:scoreboard/theme/index.dart';

class SetScoreSummary extends StatelessWidget {
  final int leftSetWins;
  final int rightSetWins;
  final Color cardColor;

  const SetScoreSummary({
    super.key,
    required this.leftSetWins,
    required this.rightSetWins,
    required this.cardColor,
  });

  Widget _scoreBox(int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$value',
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 36,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _scoreBox(leftSetWins),
        const SizedBox(width: 8),
        const Text(
          ':',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor,
            fontSize: 36,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        _scoreBox(rightSetWins),
      ],
    );
  }
}
