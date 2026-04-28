import 'package:flutter/material.dart';

class LeaderboardFooterSection extends StatelessWidget {
  final bool canFinishTogether;
  final Color accentColor;
  final VoidCallback onFinishTogether;

  const LeaderboardFooterSection({
    super.key,
    required this.canFinishTogether,
    required this.accentColor,
    required this.onFinishTogether,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canFinishTogether ? onFinishTogether : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade800,
              disabledForegroundColor: Colors.grey.shade300,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Selesai Main Bareng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}
