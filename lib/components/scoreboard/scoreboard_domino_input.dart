import 'package:flutter/material.dart';

class ScoreboardDominoInput extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const ScoreboardDominoInput({
    super.key,
    required this.controller,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      enabled: enabled,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        hintText: 'Input angka',
        hintStyle: const TextStyle(color: Colors.white70, fontSize: 12),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
