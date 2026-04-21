import 'package:flutter/material.dart';
import 'package:scoreboard/components/scoreboard/models.dart';
import 'package:scoreboard/theme/index.dart';

class ScoreHistorySection extends StatelessWidget {
  final bool isSetMode;
  final int selectedSet;
  final bool hasSetTimer;
  final String setDurationText;
  final Color accentColor;
  final String leftPlayerName;
  final String rightPlayerName;
  final Color leftPlayerColor;
  final Color rightPlayerColor;
  final List<ScoreHistoryItem> items;
  final String Function(int score) scoreTextBuilder;

  const ScoreHistorySection({
    super.key,
    required this.isSetMode,
    required this.selectedSet,
    required this.hasSetTimer,
    required this.setDurationText,
    required this.accentColor,
    required this.leftPlayerName,
    required this.rightPlayerName,
    required this.leftPlayerColor,
    required this.rightPlayerColor,
    required this.items,
    required this.scoreTextBuilder,
  });

  Color _backgroundColorFor(ScoreHistoryItem item) {
    final note = item.note.toLowerCase();
    final leftName = leftPlayerName.toLowerCase();
    final rightName = rightPlayerName.toLowerCase();

    if (note.startsWith(leftName) || note.contains('dimenangkan $leftName')) {
      return leftPlayerColor;
    }

    if (note.startsWith(rightName) || note.contains('dimenangkan $rightName')) {
      return rightPlayerColor;
    }

    return Colors.white;
  }

  Color _borderColorFor(ScoreHistoryItem item) {
    final note = item.note.toLowerCase();
    final leftName = leftPlayerName.toLowerCase();
    final rightName = rightPlayerName.toLowerCase();

    if (note.startsWith(leftName) || note.contains('dimenangkan $leftName')) {
      return leftPlayerColor.withAlpha(76);
    }

    if (note.startsWith(rightName) || note.contains('dimenangkan $rightName')) {
      return rightPlayerColor.withAlpha(76);
    }

    return const Color(0xFFE5E7EB);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Riwayat Set',
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        if (isSetMode)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withAlpha(31),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Set $selectedSet',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Durasi ${hasSetTimer ? setDurationText : '--:--'}',
                    style: const TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (items.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Text(
              'Belum ada riwayat skor.',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
        if (items.isNotEmpty)
          ...items.map((item) {
            final backgroundColor = _backgroundColorFor(item);
            final borderColor = _borderColorFor(item);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Text(
                    '${scoreTextBuilder(item.leftScore)} - ${scoreTextBuilder(item.rightScore)}',
                    style: const TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.note,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
