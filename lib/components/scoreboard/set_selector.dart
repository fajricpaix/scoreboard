import 'package:flutter/material.dart';
import 'package:scoreboard/theme/index.dart';

class SetSelector extends StatelessWidget {
  final int setCount;
  final int selectedSet;
  final Map<int, bool> setWinners;
  final Color leftPlayerColor;
  final Color rightPlayerColor;
  final Color accentColor;
  final VoidCallback onAddSet;
  final ValueChanged<int> onSelectSet;

  const SetSelector({
    super.key,
    required this.setCount,
    required this.selectedSet,
    required this.setWinners,
    required this.leftPlayerColor,
    required this.rightPlayerColor,
    required this.accentColor,
    required this.onAddSet,
    required this.onSelectSet,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: setCount + 1,
        itemBuilder: (context, index) {
          if (index == setCount) {
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: SizedBox(
                width: 38,
                child: OutlinedButton(
                  onPressed: onAddSet,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.white,
                    foregroundColor: accentColor,
                    side: BorderSide(color: accentColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Icon(Icons.add, size: 18),
                ),
              ),
            );
          }

          final setNumber = index + 1;
          final selected = setNumber == selectedSet;
          final setWinner = setWinners[setNumber];
          final hasWinner = setWinner != null;
          final winnerColor = setWinner == true
              ? leftPlayerColor
              : rightPlayerColor;
          final backgroundColor = hasWinner
              ? winnerColor
              : (selected ? accentColor : Colors.white);
          final foregroundColor = hasWinner || selected
              ? Colors.white
              : textColor;
          final borderColor = hasWinner ? winnerColor : accentColor;

          return Padding(
            padding: EdgeInsets.only(right: index == setCount - 1 ? 0 : 8),
            child: OutlinedButton(
              onPressed: () => onSelectSet(setNumber),
              style: OutlinedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                side: BorderSide(color: borderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Set $setNumber',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          );
        },
      ),
    );
  }
}
