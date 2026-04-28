import 'package:flutter/material.dart';
import 'package:scoreboard/theme/index.dart';

class StartMatchDialog extends StatefulWidget {
  final List<Map<String, String>> players;
  final int requiredPlayerCount;
  final bool isDoubleMatch;
  final Color accentColor;
  final Color Function(String gender) genderColorBuilder;
  final int Function(Map<String, String> player) playerPlayCountBuilder;
  final ValueChanged<List<Map<String, String>>> onStart;

  const StartMatchDialog({
    super.key,
    required this.players,
    required this.requiredPlayerCount,
    required this.isDoubleMatch,
    required this.accentColor,
    required this.genderColorBuilder,
    required this.playerPlayCountBuilder,
    required this.onStart,
  });

  @override
  State<StartMatchDialog> createState() => _StartMatchDialogState();
}

class _StartMatchDialogState extends State<StartMatchDialog> {
  final List<int> _selectedIndexes = [];

  @override
  Widget build(BuildContext context) {
    final selectedPlayers = _selectedIndexes
        .map((index) => widget.players[index])
        .toList();

    return AlertDialog(
      backgroundColor: const Color(0xFF323232),
      surfaceTintColor: backgroundColor,
      title: Text(
        widget.isDoubleMatch
            ? 'Pilih 4 pemain untuk ganda'
            : 'Pilih 2 pemain untuk single',
        style: const TextStyle(color: textColor, fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isDoubleMatch
                  ? 'Dua pemain pertama akan menjadi tim kiri dan dua pemain berikutnya menjadi tim kanan.'
                  : 'Pilih dua pemain yang akan langsung masuk ke scoreboard.',
              style: const TextStyle(
                color: textColor,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Terpilih ${_selectedIndexes.length}/${widget.requiredPlayerCount}',
              style: const TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (selectedPlayers.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(selectedPlayers.length, (index) {
                  final player = selectedPlayers[index];
                  final genderColor = widget.genderColorBuilder(
                    player['gender'] ?? 'Pria',
                  );
                  final orderLabel = widget.isDoubleMatch
                      ? (index < 2 ? 'Tim 1' : 'Tim 2')
                      : index == 0
                      ? 'Kiri'
                      : 'Kanan';

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: genderColor.withAlpha(31),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: genderColor.withAlpha(89)),
                    ),
                    child: Text(
                      '$orderLabel: ${player['name'] ?? '-'}',
                      style: TextStyle(
                        color: genderColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }),
              ),
            ],
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(widget.players.length, (index) {
                    final player = widget.players[index];
                    final isSelected = _selectedIndexes.contains(index);
                    final isDisabled =
                        !isSelected &&
                        _selectedIndexes.length >= widget.requiredPlayerCount;
                    final genderColor = widget.genderColorBuilder(
                      player['gender'] ?? 'Pria',
                    );
                    final playCount = widget.playerPlayCountBuilder(player);

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: isDisabled
                            ? null
                            : () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedIndexes.remove(index);
                                  } else {
                                    _selectedIndexes.add(index);
                                  }
                                });
                              },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? genderColor.withAlpha(46)
                                : genderColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? genderColor
                                  : genderColor.withAlpha(102),
                              width: isSelected ? 1.6 : 1,
                            ),
                          ),
                          child: Opacity(
                            opacity: isDisabled ? 0.45 : 1,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isSelected) ...[
                                      Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: genderColor,
                                      ),
                                      const SizedBox(width: 6),
                                    ],
                                    Flexible(
                                      child: Text(
                                        player['name'] ?? '-',
                                        style: TextStyle(
                                          color: genderColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$playCount kali main',
                                  style: TextStyle(
                                    color: genderColor.withAlpha(204),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Batal',
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          ),
        ),
        ElevatedButton(
          onPressed: _selectedIndexes.length == widget.requiredPlayerCount
              ? () {
                  final selectedPlayers = _selectedIndexes
                      .map((index) => widget.players[index])
                      .toList();
                  Navigator.of(context).pop();
                  widget.onStart(selectedPlayers);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.accentColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade800,
            disabledForegroundColor: Colors.grey.shade200,
            elevation: 0,
          ),
          child: const Text('Mulai'),
        ),
      ],
    );
  }
}
