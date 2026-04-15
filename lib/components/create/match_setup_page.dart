import 'package:flutter/material.dart';
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

  bool get _isPadel => widget.sport.name.toLowerCase().contains('padel');

  List<String> get _availableGameTypes =>
      _isPadel ? const ['Ganda'] : gameTypes;

  bool get _isFormComplete {
    final matchName = _matchNameController.text.trim();

    return isWordCountBetween1And10(matchName) &&
        _selectedGameType != null &&
        _selectedLeaderboardRank != null;
  }

  bool get _usesSetSystem {
    final sportName = widget.sport.name.toLowerCase();
    return sportName.contains('tenis') ||
        sportName.contains('padel') ||
        sportName.contains('badminton');
  }

  @override
  void initState() {
    super.initState();
    if (_isPadel) {
      _selectedGameType = 'Ganda';
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
      scoringSystem: _usesSetSystem ? 'Set' : 'Points',
      targetPoints: _usesSetSystem ? null : 21,
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
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
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
              color: Colors.black54,
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
  }) {
    final toggleColor = widget.sport.gradientColors[0];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? toggleColor : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: toggleColor, width: 1.3),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : toggleColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNextEnabled = _isFormComplete;

    return Scaffold(
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
      body: SafeArea(
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
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: Colors.white.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            widget.sport.icon,
                            color: widget.sport.gradientColors[0],
                            size: 30,
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
                            for (int i = 0; i < _availableGameTypes.length; i++)
                              SizedBox(
                                width: itemWidth,
                                child: _buildToggleButton(
                                  label: _availableGameTypes[i],
                                  selected:
                                      _selectedGameType ==
                                      _availableGameTypes[i],
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
                        final itemWidth = (constraints.maxWidth - spacing) / 2;

                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: [
                            for (
                              int i = 0;
                              i < leaderboardRankOptions.length;
                              i++
                            )
                              SizedBox(
                                width: itemWidth,
                                child: _buildToggleButton(
                                  label: leaderboardRankOptions[i],
                                  selected:
                                      _selectedLeaderboardRank ==
                                      leaderboardRankOptions[i],
                                  onTap: () {
                                    setState(() {
                                      _selectedLeaderboardRank =
                                          leaderboardRankOptions[i];
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
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.grey.shade600,
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
