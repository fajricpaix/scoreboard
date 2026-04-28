import 'package:flutter/material.dart';
import 'package:scoreboard/components/create/create_background.dart';
import 'package:scoreboard/components/create/models.dart';
import 'package:scoreboard/components/leaderboard/index.dart';
import 'package:scoreboard/pages/create/scoreboard.dart';
import 'package:scoreboard/theme/index.dart';
import 'package:scoreboard/utils/capitalize.dart';

class LeaderboardPageContent extends StatefulWidget {
  final MatchSetup matchSetup;
  final List<Map<String, String>> players;

  const LeaderboardPageContent({
    super.key,
    required this.matchSetup,
    required this.players,
  });

  @override
  State<LeaderboardPageContent> createState() => _LeaderboardPageContentState();
}

class _LeaderboardPageContentState extends State<LeaderboardPageContent> {
  final TextEditingController _playerNameController = TextEditingController();
  final List<Map<String, String>> _players = [];
  String _selectedGender = 'Pria';

  Color _playerGenderColor(String gender) {
    return gender == 'Pria' ? Colors.blue : Colors.pink;
  }

  int _playerPlayCount(Map<String, String> player) {
    return _playerStat(player, 'play');
  }

  int _playerWinCount(Map<String, String> player) {
    return _playerStat(player, 'win');
  }

  int _playerPointCount(Map<String, String> player) {
    return _playerStat(player, 'point');
  }

  int _playerStat(Map<String, String> player, String key) {
    return int.tryParse(player[key] ?? '0') ?? 0;
  }

  void _incrementPlayerStat(Map<String, String> player, String key) {
    player[key] = '${_playerStat(player, key) + 1}';
  }

  bool get _isDoubleMatch =>
      widget.matchSetup.gameType.toLowerCase().contains('ganda');

  bool get _isDomino =>
      widget.matchSetup.sport.name.toLowerCase().contains('domino');

  Color get _accentColor => widget.matchSetup.sport.gradientColors[0];

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

        _incrementPlayerStat(player, 'play');

        if (winnerNames.contains(name)) {
          _incrementPlayerStat(player, 'win');
          _incrementPlayerStat(player, 'point');
        }

        if (loserNames.contains(name)) {
          _incrementPlayerStat(player, 'lose');
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
          accentColor: _accentColor,
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
      final aPoint = _playerPointCount(a);
      final bPoint = _playerPointCount(b);
      final aWin = _playerWinCount(a);
      final bWin = _playerWinCount(b);

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

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: _accentColor,
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
      body: CreateBackground(
        imageOpacity: 0.5,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                children: [
                  LeaderboardHeaderSection(
                    matchName: widget.matchSetup.matchName,
                    sportName: widget.matchSetup.sport.name,
                    gameType: widget.matchSetup.gameType,
                    rankModeLabel: rankModeLabel,
                    playerCount: sortedPlayers.length,
                    gradientColors: widget.matchSetup.sport.gradientColors,
                  ),
                  const SizedBox(height: 16),
                  LeaderboardActionsSection(
                    canStart: canStart,
                    isDoubleMatch: _isDoubleMatch,
                    isDomino: _isDomino,
                    accentColor: _accentColor,
                    playerNameController: _playerNameController,
                    selectedGender: _selectedGender,
                    canAddPlayer: _canAddPlayer,
                    onStartMatch: _showStartMatchDialog,
                    onGenderSelected: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    onAddPlayer: _addPlayer,
                  ),
                  const SizedBox(height: 16),
                  LeaderboardPlayerListSection(
                    players: sortedPlayers,
                    accentColor: _accentColor,
                  ),
                ],
              ),
            ),
            LeaderboardFooterSection(
              canFinishTogether: _canFinishTogether,
              accentColor: _accentColor,
              onFinishTogether: _confirmFinishTogether,
            ),
          ],
        ),
      ),
    );
  }
}
