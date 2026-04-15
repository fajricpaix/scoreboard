import 'package:flutter/material.dart';
import 'package:scoreboard/components/create/models.dart';
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

    final selectedIndexes = <int>[];

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final selectedPlayers = selectedIndexes
                .map((index) => sortedPlayers[index])
                .toList();

            return AlertDialog(
              backgroundColor: backgroundColor,
              surfaceTintColor: backgroundColor,
              title: Text(
                _isDoubleMatch
                    ? 'Pilih 4 pemain untuk ganda'
                    : 'Pilih 2 pemain untuk single',
                style: const TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isDoubleMatch
                          ? 'Dua pemain pertama akan menjadi tim kiri dan dua pemain berikutnya menjadi tim kanan.'
                          : 'Pilih dua pemain yang akan langsung masuk ke scoreboard.',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Terpilih ${selectedIndexes.length}/$_requiredPlayerCount',
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
                        children: List.generate(selectedPlayers.length, (
                          index,
                        ) {
                          final player = selectedPlayers[index];
                          final orderLabel = _isDoubleMatch
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
                              color: _playerGenderColor(
                                player['gender'] ?? 'Pria',
                              ).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _playerGenderColor(
                                  player['gender'] ?? 'Pria',
                                ).withOpacity(0.35),
                              ),
                            ),
                            child: Text(
                              '$orderLabel: ${player['name'] ?? '-'}',
                              style: TextStyle(
                                color: _playerGenderColor(
                                  player['gender'] ?? 'Pria',
                                ),
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
                          children: List.generate(sortedPlayers.length, (
                            index,
                          ) {
                            final player = sortedPlayers[index];
                            final isSelected = selectedIndexes.contains(index);
                            final isDisabled =
                                !isSelected &&
                                selectedIndexes.length >= _requiredPlayerCount;
                            final genderColor = _playerGenderColor(
                              player['gender'] ?? 'Pria',
                            );
                            final playCount = _playerPlayCount(player);

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: isDisabled
                                    ? null
                                    : () {
                                        setDialogState(() {
                                          if (isSelected) {
                                            selectedIndexes.remove(index);
                                          } else {
                                            selectedIndexes.add(index);
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
                                        ? genderColor.withOpacity(0.18)
                                        : genderColor.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? genderColor
                                          : genderColor.withOpacity(0.4),
                                      width: isSelected ? 1.6 : 1,
                                    ),
                                  ),
                                  child: Opacity(
                                    opacity: isDisabled ? 0.45 : 1,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            color: genderColor.withOpacity(0.8),
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
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: selectedIndexes.length == _requiredPlayerCount
                      ? () {
                          Navigator.of(dialogContext).pop();
                          _startMatchWithPlayers(
                            selectedIndexes
                                .map((index) => sortedPlayers[index])
                                .toList(),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.matchSetup.sport.gradientColors[0],
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade600,
                    elevation: 0,
                  ),
                  child: const Text('Mulai'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool get _sortByPoint =>
      widget.matchSetup.leaderboardRankBy.toLowerCase().contains('point');

  bool get _canAddPlayer =>
      isWordCountBetween1And10(_playerNameController.text);

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
      appBar: AppBar(
        backgroundColor: primaryColor,
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
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.matchSetup.sport.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.matchSetup.matchName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Urutan rank: $rankModeLabel tertinggi',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Jumlah Pemain: ${sortedPlayers.length} pemain',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: canStart ? _showStartMatchDialog : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          widget.matchSetup.sport.gradientColors[0],
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
                Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _playerNameController,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _addPlayer(),
                              style: const TextStyle(color: textColor),
                              decoration: InputDecoration(
                                labelText: 'Nama pemain',
                                hintText: 'Contoh: John Doe',
                                labelStyle: const TextStyle(color: textColor),
                                floatingLabelStyle: const TextStyle(
                                  color: textColor,
                                ),
                                hintStyle: const TextStyle(color: textColor),
                                prefixIcon: PopupMenuButton<String>(
                                  tooltip: 'Pilih gender',
                                  color: Colors.white,
                                  initialValue: _selectedGender,
                                  onSelected: (value) {
                                    setState(() {
                                      _selectedGender = value;
                                    });
                                  },
                                  icon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _selectedGender == 'Pria'
                                            ? Icons.male
                                            : Icons.female,
                                        color: _selectedGender == 'Pria'
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
                                          Icon(
                                            Icons.male,
                                            size: 18,
                                            color: Colors.blue,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Pria',
                                            style: TextStyle(color: textColor),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'Wanita',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.female,
                                            size: 18,
                                            color: Colors.pink,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Wanita',
                                            style: TextStyle(color: textColor),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE5E7EB),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE5E7EB),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: widget
                                        .matchSetup
                                        .sport
                                        .gradientColors[0],
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 52,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _canAddPlayer ? _addPlayer : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    widget.matchSetup.sport.gradientColors[0],
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey.shade300,
                                disabledForegroundColor: Colors.grey.shade600,
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
                      ),
                const SizedBox(height: 16),
                ...List.generate(sortedPlayers.length, (index) {
                  final player = sortedPlayers[index];
                  final isMale = (player['gender'] ?? 'Pria') == 'Pria';
                  final name = player['name'] ?? '-';
                  final point = player['point'] ?? '0';
                  final win = player['win'] ?? '0';
                  final lose = player['lose'] ?? '0';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: widget
                              .matchSetup
                              .sport
                              .gradientColors[0]
                              .withOpacity(0.18),
                          foregroundColor:
                              widget.matchSetup.sport.gradientColors[0],
                          child: Text('${index + 1}'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Icon(
                                    isMale ? Icons.male : Icons.female,
                                    size: 13,
                                    color: isMale ? Colors.blue : Colors.pink,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    player['gender'] ?? 'Pria',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Point: $point',
                              style: const TextStyle(
                                color: textColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Win: $win •',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  ' Lose: $lose',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ])
                          ],
                        ),
                      ],
                    ),
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
                    backgroundColor: widget.matchSetup.sport.gradientColors[0],
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
                    'Selesai Main Bareng',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
