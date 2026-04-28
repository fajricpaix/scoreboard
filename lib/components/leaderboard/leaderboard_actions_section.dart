import 'package:flutter/material.dart';
import 'package:scoreboard/components/leaderboard/player_input_bar.dart';

class LeaderboardActionsSection extends StatelessWidget {
  final bool canStart;
  final bool isDoubleMatch;
  final bool isDomino;
  final Color accentColor;
  final TextEditingController playerNameController;
  final String selectedGender;
  final bool canAddPlayer;
  final VoidCallback onStartMatch;
  final ValueChanged<String> onGenderSelected;
  final VoidCallback onAddPlayer;

  const LeaderboardActionsSection({
    super.key,
    required this.canStart,
    required this.isDoubleMatch,
    required this.isDomino,
    required this.accentColor,
    required this.playerNameController,
    required this.selectedGender,
    required this.canAddPlayer,
    required this.onStartMatch,
    required this.onGenderSelected,
    required this.onAddPlayer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: canStart ? onStartMatch : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.grey.shade600,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(
              isDoubleMatch
                  ? 'Mulai Pertandingan Ganda'
                  : 'Mulai Pertandingan Single',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        if (!isDomino) ...[
          const SizedBox(height: 16),
          PlayerInputBar(
            controller: playerNameController,
            selectedGender: selectedGender,
            canAddPlayer: canAddPlayer,
            accentColor: accentColor,
            onGenderSelected: onGenderSelected,
            onAddPlayer: onAddPlayer,
          ),
        ],
      ],
    );
  }
}
