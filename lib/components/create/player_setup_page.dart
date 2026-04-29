import 'package:flutter/material.dart';
import 'package:scoreboard/components/create/create_background.dart';
import 'package:scoreboard/components/create/models.dart';
import 'package:scoreboard/pages/create/leaderboard.dart';
import 'package:scoreboard/theme/index.dart';
import 'package:scoreboard/utils/capitalize.dart';

class _PlayerItem {
  final String name;
  final String gender;

  const _PlayerItem({required this.name, required this.gender});
}

class PlayerSetupPage extends StatefulWidget {
  final MatchSetup matchSetup;

  const PlayerSetupPage({super.key, required this.matchSetup});

  @override
  State<PlayerSetupPage> createState() => _PlayerSetupPageState();
}

class _PlayerSetupPageState extends State<PlayerSetupPage> {
  final TextEditingController _playerNameController = TextEditingController();
  final List<_PlayerItem> _players = [];
  String _selectedGender = 'Pria';

  bool get _isDomino =>
      widget.matchSetup.sport.name.toLowerCase().contains('domino');

  bool get _canAddPlayer =>
      isWordCountBetween1And10(_playerNameController.text) &&
      (!_isDomino || _players.length < 4);
  bool get _canGoToScoreboard =>
      _isDomino ? _players.length == 4 : _players.length >= 2;

  @override
  void initState() {
    super.initState();
    _playerNameController.addListener(_onPlayerNameChanged);
  }

  @override
  void dispose() {
    _playerNameController
      ..removeListener(_onPlayerNameChanged)
      ..dispose();
    super.dispose();
  }

  void _onPlayerNameChanged() {
    setState(() {});
  }

  void _addPlayer() {
    final playerName = _playerNameController.text.trim();
    if (!isWordCountBetween1And10(playerName)) {
      return;
    }

    setState(() {
      _players.add(
        _PlayerItem(name: capitalizeWords(playerName), gender: _selectedGender),
      );
      _playerNameController.clear();
    });
  }

  void _removePlayer(int index) {
    setState(() {
      _players.removeAt(index);
    });
  }

  void _goToScoreboard() {
    if (!_canGoToScoreboard) {
      return;
    }

    final players = _players.map((player) {
      return {
        'name': player.name,
        'gender': player.gender,
        'point': '0',
        'win': '0',
        'lose': '0',
        'play': '0',
      };
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            LeaderboardPage(matchSetup: widget.matchSetup, players: players),
      ),
    );
  }

  Widget _buildSummaryTile({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matchSetup = widget.matchSetup;
    final scoringValue = matchSetup.scoringSystem == 'Points'
        ? '${matchSetup.targetPoints} point'
        : '${matchSetup.targetSets} set';

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: matchSetup.sport.gradientColors[0],
        elevation: 0,
        titleSpacing: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Input Pemain',
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
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: matchSetup.sport.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          matchSetup.matchName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${matchSetup.sport.name} • ${matchSetup.gameType}',
                          style: TextStyle(
                            // ignore: deprecated_member_use
                            color: Colors.white.withOpacity(0.82),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    runSpacing: 12,
                    spacing: 12,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: _buildSummaryTile(
                          icon: Icons.scoreboard_outlined,
                          label: 'Scoring system',
                          value: '${matchSetup.scoringSystem} • $scoringValue',
                          iconColor: matchSetup.sport.gradientColors[0],
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: _buildSummaryTile(
                          icon: Icons.leaderboard_outlined,
                          label: 'Leaderboard rank',
                          value: matchSetup.leaderboardRankBy,
                          iconColor: matchSetup.sport.gradientColors[0],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Nama Pemain',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isDomino
                        ? 'Domino membutuhkan tepat 4 pemain.'
                        : 'Tambahkan nama pemain satu per satu, lalu cek daftar pemain di bawah.',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
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
                            prefixIconColor: matchSetup.sport.gradientColors[0],
                            prefixIcon: PopupMenuButton<String>(
                              tooltip: 'Pilih gender',
                              color: backgroundColor,
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
                              itemBuilder: (context) => [
                                PopupMenuItem<String>(
                                  value: 'Pria',
                                  textStyle: const TextStyle(color: textColor),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.male,
                                        size: 18,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Pria',
                                        style: TextStyle(color: textColor),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem<String>(
                                  value: 'Wanita',
                                  textStyle: const TextStyle(color: textColor),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.female,
                                        size: 18,
                                        color: Colors.pink,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Wanita',
                                        style: TextStyle(color: textColor),
                                      ),
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
                              borderSide: BorderSide(
                                color: matchSetup.sport.gradientColors[0],
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: matchSetup.sport.gradientColors[0],
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: matchSetup.sport.gradientColors[0],
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
                            backgroundColor: matchSetup.sport.gradientColors[0],
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
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      const Text(
                        'List Pemain',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_players.length} pemain',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_players.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFF7E0101)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.groups_outlined, color: Colors.white54),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Belum ada pemain. Tambahkan nama pemain untuk membentuk daftar peserta.',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_players.isNotEmpty)
                    ...List.generate(_players.length, (index) {
                      final player = _players[index];
                      final isMale = player.gender == 'Pria';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF5B5B5B),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              // ignore: deprecated_member_use
                              backgroundColor: matchSetup.sport.gradientColors[0].withOpacity(0.3),
                              foregroundColor:
                                  matchSetup.sport.gradientColors[0],
                              child: Text('${index + 1}'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    player.name,
                                    style: const TextStyle(
                                      color: textColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isMale ? Icons.male : Icons.female,
                                        size: 14,
                                        color: isMale
                                            ? Colors.blue
                                            : Colors.pink,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        player.gender,
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _removePlayer(index),
                              icon: const Icon(Icons.close_rounded),
                              color: Colors.white54,
                              tooltip: 'Hapus pemain',
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
            if (_canGoToScoreboard)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _goToScoreboard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            widget.matchSetup.sport.gradientColors[0],
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
