import 'package:flutter/material.dart';
import 'package:scoreboard/services/match_history_service.dart';
import 'package:scoreboard/theme/index.dart';

class HistoryDetailPage extends StatelessWidget {
  final MatchHistoryRecord record;

  const HistoryDetailPage({super.key, required this.record});

  String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}j ${minutes}m ${seconds}d';
    }
    return '${minutes}m ${seconds}d';
  }

  bool get _usesTennisSequence {
    final sport = record.sport.toLowerCase();
    return (sport.contains('tenis') && !sport.contains('tenis meja')) ||
        sport.contains('padel');
  }

  String _scoreText(int score) {
    if (!_usesTennisSequence) {
      return '$score';
    }

    switch (score) {
      case 0:
        return '0';
      case 1:
        return '15';
      case 2:
        return '30';
      case 3:
        return '40';
      default:
        return 'AD';
    }
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: textColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Detail Pertandingan',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.matchName,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _infoTile('Olahraga', record.sport),
                _infoTile('Pemain', record.playerLabel),
                _infoTile(
                  'Hasil',
                  '${record.scoreLabel} • ${record.winnerLabel}',
                ),
                _infoTile('Mulai', _formatDateTime(record.startedAt)),
                _infoTile('Selesai', _formatDateTime(record.finishedAt)),
                _infoTile('Durasi', _formatDuration(record.duration)),
                _infoTile(
                  'Mode',
                  '${record.gameType} • ${record.scoringSystem}',
                ),
              ],
            ),
          ),
          if (record.sets.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan Set',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStatePropertyAll(
                        Colors.white.withAlpha(18),
                      ),
                      columns: [
                        const DataColumn(
                          label: Text(
                            'Set',
                            style: TextStyle(color: textColor),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            record.leftPlayerName,
                            style: const TextStyle(color: textColor),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            record.rightPlayerName,
                            style: const TextStyle(color: textColor),
                          ),
                        ),
                        const DataColumn(
                          label: Text(
                            'Pemenang',
                            style: TextStyle(color: textColor),
                          ),
                        ),
                      ],
                      rows: record.sets
                          .map(
                            (set) => DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    '${set.setNumber}',
                                    style: const TextStyle(color: textColor),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    _scoreText(set.leftScore),
                                    style: const TextStyle(color: textColor),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    _scoreText(set.rightScore),
                                    style: const TextStyle(color: textColor),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    set.leftWon == null
                                        ? '-'
                                        : (set.leftWon!
                                              ? record.leftPlayerName
                                              : record.rightPlayerName),
                                    style: const TextStyle(color: textColor),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Riwayat Skor',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                if (record.scoreHistory.isEmpty)
                  const Text(
                    'Belum ada detail skor yang tersimpan.',
                    style: TextStyle(color: Colors.white70),
                  )
                else
                  ...record.scoreHistory.asMap().entries.map((entry) {
                    final item = entry.value;
                    final setLabel = item.setNumber == null
                        ? 'Ronde'
                        : 'Set ${item.setNumber}';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(30),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$setLabel • ${_scoreText(item.leftScore)}-${_scoreText(item.rightScore)}',
                                  style: const TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.note,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
