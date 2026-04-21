import 'package:flutter/material.dart';
import 'package:scoreboard/theme/index.dart';

class PlayerInputBar extends StatelessWidget {
  final TextEditingController controller;
  final String selectedGender;
  final bool canAddPlayer;
  final Color accentColor;
  final ValueChanged<String> onGenderSelected;
  final VoidCallback onAddPlayer;

  const PlayerInputBar({
    super.key,
    required this.controller,
    required this.selectedGender,
    required this.canAddPlayer,
    required this.accentColor,
    required this.onGenderSelected,
    required this.onAddPlayer,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onAddPlayer(),
            style: const TextStyle(color: textColor),
            decoration: InputDecoration(
              labelText: 'Nama pemain',
              hintText: 'Contoh: John Doe',
              labelStyle: const TextStyle(color: textColor),
              floatingLabelStyle: const TextStyle(color: textColor),
              hintStyle: const TextStyle(color: textColor),
              prefixIcon: PopupMenuButton<String>(
                tooltip: 'Pilih gender',
                color: backgroundColor,
                initialValue: selectedGender,
                onSelected: onGenderSelected,
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      selectedGender == 'Pria' ? Icons.male : Icons.female,
                      color: selectedGender == 'Pria'
                          ? Colors.blue
                          : Colors.pink,
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.arrow_drop_down,
                      size: 16,
                      color: textColor,
                    ),
                  ],
                ),
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(
                    value: 'Pria',
                    child: Row(
                      children: [
                        Icon(Icons.male, size: 18, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Pria', style: TextStyle(color: textColor)),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'Wanita',
                    child: Row(
                      children: [
                        Icon(Icons.female, size: 18, color: Colors.pink),
                        SizedBox(width: 8),
                        Text('Wanita', style: TextStyle(color: textColor)),
                      ],
                    ),
                  ),
                ],
              ),
              filled: true,
              fillColor: backgroundColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: accentColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: accentColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: accentColor, width: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 52,
          height: 52,
          child: ElevatedButton(
            onPressed: canAddPlayer ? onAddPlayer : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade800,
              disabledForegroundColor: Colors.grey.shade300,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
