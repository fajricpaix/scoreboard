import 'package:flutter/material.dart';

class ScoreboardPrimaryActionSection extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color accentColor;
  final String buttonLabel;
  final String? helperText;

  const ScoreboardPrimaryActionSection({
    super.key,
    required this.onPressed,
    required this.accentColor,
    required this.buttonLabel,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade800,
              disabledForegroundColor: Colors.grey.shade300,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              buttonLabel,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 10),
          Text(
            helperText!,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ],
    );
  }
}
