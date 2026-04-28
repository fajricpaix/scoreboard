import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scoreboard/components/create/models.dart';
import 'package:scoreboard/components/create/player_setup_page.dart';
import 'package:scoreboard/theme/index.dart';
import 'package:scoreboard/utils/capitalize.dart';

class MatchSetupPage extends StatefulWidget {
  final Sport sport;

  const MatchSetupPage({super.key, required this.sport});

  @override
  State<MatchSetupPage> createState() => _MatchSetupPageState();
}

class _MatchSetupPageState extends State<MatchSetupPage> {
  final TextEditingController _matchNameController = TextEditingController();

  String? _selectedGameType;
  String? _selectedLeaderboardRank;
  String? _selectedDominoScoreMode;

  bool get _isPadel => widget.sport.name.toLowerCase().contains('padel');
  bool get _isDomino => widget.sport.name.toLowerCase().contains('domino');

  List<String> get _availableGameTypes =>
      (_isPadel || _isDomino) ? const ['Ganda'] : gameTypes;

  List<String> get _availableLeaderboardRanks =>
      _isDomino ? const ['Kemenangan'] : leaderboardRankOptions;

  bool get _isFormComplete {
    final matchName = _matchNameController.text.trim();

    return isWordCountBetween1And10(matchName) &&
        _selectedGameType != null &&
        _selectedLeaderboardRank != null &&
        (!_isDomino || _selectedDominoScoreMode != null);
  }

  bool get _usesSetSystem {
    final sportName = widget.sport.name.toLowerCase();
    final isTableTennis = sportName.contains('tenis meja');
    return sportName.contains('tenis') ||
        isTableTennis ||
        sportName.contains('padel') ||
        sportName.contains('badminton');
  }

  @override
  void initState() {
    super.initState();
    if (_isPadel || _isDomino) {
      _selectedGameType = 'Ganda';
    }
    if (_isDomino) {
      _selectedLeaderboardRank = 'Kemenangan';
      _selectedDominoScoreMode = dominoScoreModeOptions.first;
    }
    _matchNameController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _matchNameController
      ..removeListener(_onFormChanged)
      ..dispose();
    super.dispose();
  }

  void _onFormChanged() {
    setState(() {});
  }

  void _goToPlayerSetup() {
    if (!_isFormComplete) {
      return;
    }

    final matchSetup = MatchSetup(
      sport: widget.sport,
      matchName: capitalizeWords(_matchNameController.text),
      gameType: _selectedGameType!,
      dominoScoreMode: _selectedDominoScoreMode ?? dominoScoreModeOptions.first,
      scoringSystem: _usesSetSystem ? 'Set' : 'Points',
      targetPoints: _usesSetSystem ? null : (_isDomino ? 101 : 21),
      targetSets: _usesSetSystem ? 2 : null,
      leaderboardRankBy: _selectedLeaderboardRank!,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerSetupPage(matchSetup: matchSetup),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    Widget? prefixIcon,
  }) {
    final iconColor = widget.sport.gradientColors[0];
    final focusedColor = widget.sport.gradientColors[0];

    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: textColor),
      floatingLabelStyle: const TextStyle(color: textColor),
      hintStyle: const TextStyle(color: textColor),
      prefixIconColor: iconColor,
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: backgroundColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: iconColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: iconColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: focusedColor, width: 1.5),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[800]!,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    bool locked = false,
  }) {
    final toggleColor = widget.sport.gradientColors[0];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: locked ? null : onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? toggleColor : backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: toggleColor, width: 1.3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? Colors.white : toggleColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (locked) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.lock_rounded,
                  size: 13,
                  color: selected ? Colors.white70 : toggleColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNextEnabled = _isFormComplete;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        titleSpacing: 0,
        leading: const BackButton(color: Colors.white),
        title: Text(
          widget.sport.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child : ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Opacity(
                opacity: 0.35,
                child: Image.asset(
                  'assets/icon/match_vector.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              )
          ),
          SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 18),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: widget.sport.gradientColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                // ignore: deprecated_member_use
                                color: Colors.white.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: SvgPicture.asset(
                                widget.sport.iconAsset,
                                width: 30,
                                height: 30,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Atur Detail Pertandingan',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.sport.description,
                                    style: TextStyle(
                                      // ignore: deprecated_member_use
                                      color: Colors.white.withOpacity(0.82),
                                      fontSize: 12,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildSection(
                        title: 'Nama Pertandingan',
                        subtitle:
                            'Masukkan nama pertandingan yang akan tampil di leaderboard.',
                        child: TextField(
                          controller: _matchNameController,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(color: textColor),
                          decoration: _inputDecoration(
                            label: 'Nama Pertandingan',
                            hint: 'Contoh: Friday Night Padel',
                            prefixIcon: const Icon(Icons.emoji_events_outlined),
                          ),
                        ),
                      ),
                      _buildSection(
                        title: 'Tipe Permainan',
                        subtitle: _isPadel
                            ? 'Padel hanya tersedia untuk mode ganda.'
                            : 'Pilih mode permainan single atau ganda.',
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            const spacing = 10.0;
                            final itemCount = _availableGameTypes.length;
                            final itemWidth = itemCount == 1
                                ? constraints.maxWidth
                                : (constraints.maxWidth - spacing) / 2;

                            return Wrap(
                              spacing: spacing,
                              runSpacing: spacing,
                              children: [
                                for (
                                  int i = 0;
                                  i < _availableGameTypes.length;
                                  i++
                                )
                                  SizedBox(
                                    width: itemWidth,
                                    child: _buildToggleButton(
                                      label: _availableGameTypes[i],
                                      selected:
                                          _selectedGameType ==
                                          _availableGameTypes[i],
                                      locked: _availableGameTypes.length == 1,
                                      onTap: () {
                                        setState(() {
                                          _selectedGameType =
                                              _availableGameTypes[i];
                                        });
                                      },
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                      _buildSection(
                        title: 'Leaderboard Rank',
                        subtitle:
                            'Tentukan peringkat leaderboard berdasarkan point atau kemenangan.',
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            const spacing = 10.0;
                            final itemWidth =
                                _availableLeaderboardRanks.length == 1
                                ? constraints.maxWidth
                                : (constraints.maxWidth - spacing) / 2;

                            return Wrap(
                              spacing: spacing,
                              runSpacing: spacing,
                              children: [
                                for (
                                  int i = 0;
                                  i < _availableLeaderboardRanks.length;
                                  i++
                                )
                                  SizedBox(
                                    width: itemWidth,
                                    child: _buildToggleButton(
                                      label: _availableLeaderboardRanks[i],
                                      selected:
                                          _selectedLeaderboardRank ==
                                          _availableLeaderboardRanks[i],
                                      locked:
                                          _availableLeaderboardRanks.length ==
                                          1,
                                      onTap: () {
                                        setState(() {
                                          _selectedLeaderboardRank =
                                              _availableLeaderboardRanks[i];
                                        });
                                      },
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                      if (_isDomino)
                        _buildSection(
                          title: 'Mode Skor Domino',
                          subtitle:
                              'Biasa: skor tim hanya ditambah. Reset Angka: saat tim lawan diinput, skor tim sebelumnya otomatis jadi 0.',
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              const spacing = 10.0;
                              final itemWidth =
                                  (constraints.maxWidth - spacing) / 2;

                              return Wrap(
                                spacing: spacing,
                                runSpacing: spacing,
                                children: [
                                  for (
                                    int i = 0;
                                    i < dominoScoreModeOptions.length;
                                    i++
                                  )
                                    SizedBox(
                                      width: itemWidth,
                                      child: _buildToggleButton(
                                        label: dominoScoreModeOptions[i],
                                        selected:
                                            _selectedDominoScoreMode ==
                                            dominoScoreModeOptions[i],
                                        onTap: () {
                                          setState(() {
                                            _selectedDominoScoreMode =
                                                dominoScoreModeOptions[i];
                                          });
                                        },
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
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
                        onPressed: isNextEnabled ? _goToPlayerSetup : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isNextEnabled
                              ? widget.sport.gradientColors[0]
                              : Colors.grey.shade300,
                          foregroundColor: isNextEnabled
                              ? Colors.white
                              : Colors.grey.shade600,
                          disabledBackgroundColor: Colors.grey.shade800,
                          disabledForegroundColor: Colors.grey.shade500,
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
        ],
      ),
    );
  }
}
