import 'package:flutter/material.dart';
import 'package:scoreboard/theme/index.dart';

class LeaderboardPlayerTile extends StatelessWidget {
  final int rank;
  final Map<String, String> player;
  final Color accentColor;

  const LeaderboardPlayerTile({
    super.key,
    required this.rank,
    required this.player,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isMale = (player['gender'] ?? 'Pria') == 'Pria';
    final name = player['name'] ?? '-';
    final point = player['point'] ?? '0';
    final win = player['win'] ?? '0';
    final lose = player['lose'] ?? '0';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: accentColor.withAlpha(46),
            foregroundColor: accentColor,
            child: Text('$rank'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      isMale ? Icons.male : Icons.female,
                      size: 13,
                      color: isMale ? Colors.blue : Colors.pink,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      player['gender'] ?? 'Pria',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Point: $point',
                style: const TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Win: $win •',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    ' Lose: $lose',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
