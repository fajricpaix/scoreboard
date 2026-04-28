import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:scoreboard/components/create/models.dart';
import 'package:scoreboard/components/leaderboard/leaderboard_player_tile.dart';
import 'package:scoreboard/components/leaderboard/leaderboard_summary_card.dart';
import 'package:scoreboard/components/leaderboard/player_input_bar.dart';
import 'package:scoreboard/components/leaderboard/start_match_dialog.dart';
import 'package:scoreboard/pages/create/scoreboard.dart';
import 'package:scoreboard/theme/index.dart';
import 'package:scoreboard/utils/capitalize.dart';

class LeaderboardPage extends StatefulWidget {
  final MatchSetup matchSetup;
  final List<Map<String, String>> players;

  const LeaderboardPage({
    super.key,
    required this.matchSetup,
    required this.players,
  });

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final TextEditingController _playerNameController = TextEditingController();
  final List<Map<String, String>> _players = [];
  String _selectedGender = 'Pria';

  Color _playerGenderColor(String gender) {
    return gender == 'Pria' ? Colors.blue : Colors.pink;
  }

  int _playerPlayCount(Map<String, String> player) {
    return int.tryParse(player['play'] ?? '0') ?? 0;
  }

  int _playerLossCount(Map<String, String> player) {
    return int.tryParse(player['lose'] ?? '0') ?? 0;
  }

  bool get _isDoubleMatch =>
      widget.matchSetup.gameType.toLowerCase().contains('ganda');

    bool get _isDomino =>
      widget.matchSetup.sport.name.toLowerCase().contains('domino');

  int get _requiredPlayerCount => _isDoubleMatch ? 4 : 2;

  bool get _canFinishTogether =>
      _players.any((player) => _playerPlayCount(player) > 0);

  Future<void> _confirmClose() async {
    final shouldClose = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          surfaceTintColor: backgroundColor,
          title: const Text(
            'Batalkan pembuatan leaderboard?',
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          ),
          content: const Text(
            'Perubahan yang belum disimpan akan hilang jika Anda keluar dari halaman ini.',
            style: TextStyle(color: textColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'Kembali',
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );

    if (shouldClose == true && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _confirmFinishTogether() async {
    final shouldFinish = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          surfaceTintColor: backgroundColor,
          title: const Text(
            'Selesaikan main bareng?',
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          ),
          content: const Text(
            'Session main bareng akan ditutup dan Anda akan kembali ke halaman home.',
            style: TextStyle(color: textColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'Kembali',
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Selesai'),
            ),
          ],
        );
      },
    );

    if (shouldFinish == true && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _startMatchWithPlayers(
    List<Map<String, String>> selectedPlayers,
  ) async {
    if (selectedPlayers.length != _requiredPlayerCount) {
      return;
    }

    final matchStartedAt = DateTime.now();
    final leftPlayers = selectedPlayers
        .take(_isDoubleMatch ? 2 : 1)
        .map((player) => player['name'] ?? '-')
        .toList();
    final rightPlayers = selectedPlayers
        .skip(_isDoubleMatch ? 2 : 1)
        .map((player) => player['name'] ?? '-')
        .toList();

    final leftPlayerName = _isDoubleMatch
        ? leftPlayers.join(' / ')
        : leftPlayers.first;
    final rightPlayerName = _isDoubleMatch
        ? rightPlayers.join(' / ')
        : rightPlayers.first;

    final result = await Navigator.push<MatchResult>(
      context,
      MaterialPageRoute(
        builder: (_) => ScoreboardPage(
          matchSetup: widget.matchSetup,
          leftPlayerName: leftPlayerName,
          rightPlayerName: rightPlayerName,
          startedAt: matchStartedAt,
          leftPlayers: leftPlayers,
          rightPlayers: rightPlayers,
        ),
      ),
    );

    if (result == null || !mounted) {
      return;
    }

    final winnerNames = result.winnerNames.toSet();
    final loserNames = result.loserNames.toSet();

    setState(() {
      for (final player in _players) {
        final name = player['name'];
        if (name == null) {
          continue;
        }

        if (!winnerNames.contains(name) && !loserNames.contains(name)) {
          continue;
        }

        final currentPlay = _playerPlayCount(player);
        player['play'] = '${currentPlay + 1}';

        if (winnerNames.contains(name)) {
          final currentWin = int.tryParse(player['win'] ?? '0') ?? 0;
          final currentPoint = int.tryParse(player['point'] ?? '0') ?? 0;
          player['win'] = '${currentWin + 1}';
          player['point'] = '${currentPoint + 1}';
        }

        if (loserNames.contains(name)) {
          final currentLose = _playerLossCount(player);
          player['lose'] = '${currentLose + 1}';
        }
      }
    });

    final winnerLabel = result.winnerNames.join(', ');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pertandingan selesai. Pemenang: $winnerLabel')),
    );
  }

  Future<void> _showStartMatchDialog() async {
    final sortedPlayers = _sortedPlayers;
    if (sortedPlayers.length < _requiredPlayerCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isDoubleMatch
                ? 'Tambahkan minimal 4 pemain untuk pertandingan ganda.'
                : 'Tambahkan minimal 2 pemain untuk pertandingan single.',
          ),
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (_) {
        return StartMatchDialog(
          players: sortedPlayers,
          requiredPlayerCount: _requiredPlayerCount,
          isDoubleMatch: _isDoubleMatch,
          accentColor: widget.matchSetup.sport.gradientColors[0],
          genderColorBuilder: _playerGenderColor,
          playerPlayCountBuilder: _playerPlayCount,
          onStart: _startMatchWithPlayers,
        );
      },
    );
  }

  bool get _sortByPoint =>
      widget.matchSetup.leaderboardRankBy.toLowerCase().contains('point');

  bool get _canAddPlayer =>
      !_isDomino && isWordCountBetween1And10(_playerNameController.text);

  List<Map<String, String>> get _sortedPlayers {
    final sorted = [..._players];
    sorted.sort((a, b) {
      final aPoint = int.tryParse(a['point'] ?? '0') ?? 0;
      final bPoint = int.tryParse(b['point'] ?? '0') ?? 0;
      final aWin = int.tryParse(a['win'] ?? '0') ?? 0;
      final bWin = int.tryParse(b['win'] ?? '0') ?? 0;

      final primary = _sortByPoint
          ? bPoint.compareTo(aPoint)
          : bWin.compareTo(aWin);
      if (primary != 0) {
        return primary;
      }

      final secondary = _sortByPoint
          ? bWin.compareTo(aWin)
          : bPoint.compareTo(aPoint);
      if (secondary != 0) {
        return secondary;
      }

      return (a['name'] ?? '').compareTo(b['name'] ?? '');
    });
    return sorted;
  }

  @override
  void initState() {
    super.initState();
    _players.addAll(widget.players.map(Map<String, String>.from));
    _playerNameController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _playerNameController
      ..removeListener(_onFormChanged)
      ..dispose();
    super.dispose();
  }

  void _onFormChanged() {
    setState(() {});
  }

  void _addPlayer() {
    if (_isDomino) {
      return;
    }

    final rawName = _playerNameController.text.trim();
    if (!isWordCountBetween1And10(rawName)) {
      return;
    }

    setState(() {
      _players.add({
        'name': capitalizeWords(rawName),
        'gender': _selectedGender,
        'point': '0',
        'win': '0',
        'lose': '0',
        'play': '0',
      });
      _playerNameController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sortedPlayers = _sortedPlayers;
    final rankModeLabel = _sortByPoint ? 'Point' : 'Kemenangan';
    final canStart = sortedPlayers.length >= _requiredPlayerCount;
    final accentColor = widget.matchSetup.sport.gradientColors[0];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: accentColor,
        elevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: _confirmClose,
          tooltip: 'Tutup',
        ),
        title: const Text(
          'Leaderboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Opacity(
                opacity: 0.5,
                child: Image.asset(
                  'assets/icon/match_vector.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              children: [
                LeaderboardSummaryCard(
                  matchName: widget.matchSetup.matchName,
                  sportName: widget.matchSetup.sport.name,
                  gameType: widget.matchSetup.gameType,
                  rankModeLabel: rankModeLabel,
                  playerCount: sortedPlayers.length,
                  gradientColors: widget.matchSetup.sport.gradientColors,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: canStart ? _showStartMatchDialog : null,
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
                      _isDoubleMatch
                          ? 'Mulai Pertandingan Ganda'
                          : 'Mulai Pertandingan Single',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (!_isDomino) ...[
                  PlayerInputBar(
                    controller: _playerNameController,
                    selectedGender: _selectedGender,
                    canAddPlayer: _canAddPlayer,
                    accentColor: accentColor,
                    onGenderSelected: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    onAddPlayer: _addPlayer,
                  ),
                  const SizedBox(height: 16),
                ],
                ...List.generate(sortedPlayers.length, (index) {
                  return LeaderboardPlayerTile(
                    rank: index + 1,
                    player: sortedPlayers[index],
                    accentColor: accentColor,
                  );
                }),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canFinishTogether ? _confirmFinishTogether : null,
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
          ),
        ],
      ),
        ],
      ),
    );
  }
}
