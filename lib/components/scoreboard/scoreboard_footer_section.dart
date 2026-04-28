import 'package:flutter/material.dart';

class ScoreboardFooterSection extends StatelessWidget {
  final bool canFinalizeMatch;
  final Color accentColor;
  final VoidCallback onFinishMatch;

  const ScoreboardFooterSection({
    super.key,
    required this.canFinalizeMatch,
    required this.accentColor,
    required this.onFinishMatch,
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
            onPressed: canFinalizeMatch ? onFinishMatch : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.grey.shade600,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Pertandingan Selesai',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}
