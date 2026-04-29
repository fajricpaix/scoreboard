import 'package:flutter/material.dart';
import 'package:scoreboard/pages/history/detail.dart';
import 'package:scoreboard/services/match_history_service.dart';
import 'package:scoreboard/theme/index.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<Map<String, List<MatchHistoryRecord>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _loadHistory();
  }

  Future<Map<String, List<MatchHistoryRecord>>> _loadHistory() async {
    return MatchHistoryService.loadLatestMatchesBySport(limitPerSport: 5);
  }

  Future<void> _refreshHistory() async {
    final future = _loadHistory();
    setState(() {
      _historyFuture = future;
    });
    await future;
  }

  String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  IconData _sportIcon(String sport) {
    final lower = sport.toLowerCase();
    if (lower.contains('badminton')) {
      return Icons.sports_tennis;
    }
    if (lower.contains('tenis meja')) {
      return Icons.sports_tennis;
    }
    if (lower.contains('tenis')) {
      return Icons.sports_tennis;
    }
    if (lower.contains('padel')) {
      return Icons.sports_tennis;
    }
    if (lower.contains('domino')) {
      return Icons.grid_view_rounded;
    }
    return Icons.emoji_events_outlined;
  }

  Future<void> _openDetail(MatchHistoryRecord record) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HistoryDetailPage(record: record)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: FutureBuilder<Map<String, List<MatchHistoryRecord>>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final groupedHistory = snapshot.data ?? const {};

          return RefreshIndicator(
            onRefresh: _refreshHistory,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                if (groupedHistory.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.history_toggle_off,
                          color: Colors.white70,
                          size: 44,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'History kosong.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Belum ada pertandingan yang tersimpan di device ini. Selesaikan pertandingan terlebih dulu, lalu history akan muncul otomatis di sini.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, height: 1.4),
                        ),
                      ],
                    ),
                  )
                else
                  ...groupedHistory.entries.map((entry) {
                    final sport = entry.key;
                    final records = entry.value;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _sportIcon(sport),
                                color: textColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  sport,
                                  style: const TextStyle(
                                    color: textColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(10),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '${records.length} match',
                                  style: const TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...records.map((record) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: ListTile(
                                onTap: () => _openDetail(record),
                                leading: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: primaryColor.withAlpha(45),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.sports_score,
                                    color: textColor,
                                  ),
                                ),
                                title: Text(
                                  record.matchName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: Text(
                                  'Waktu main: ${_formatDateTime(record.finishedAt)}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white70,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}
