import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scoreboard/components/create/models.dart';
import 'package:scoreboard/components/scoreboard/match_summary_card.dart';
import 'package:scoreboard/components/scoreboard/models.dart';
import 'package:scoreboard/components/scoreboard/player_score_card.dart';
import 'package:scoreboard/components/scoreboard/score_history_section.dart';
import 'package:scoreboard/components/scoreboard/set_score_summary.dart';
import 'package:scoreboard/components/scoreboard/set_selector.dart';
import 'package:scoreboard/theme/index.dart';

class MatchResult {
  final List<String> winnerNames;
  final List<String> loserNames;

  const MatchResult({required this.winnerNames, required this.loserNames});
}

class _SetScore {
  final int leftScore;
  final int rightScore;

  const _SetScore({required this.leftScore, required this.rightScore});
}

class ScoreboardPage extends StatefulWidget {
  final MatchSetup matchSetup;
  final String leftPlayerName;
  final String rightPlayerName;
  final DateTime startedAt;
  final List<String> leftPlayers;
  final List<String> rightPlayers;

  const ScoreboardPage({
    super.key,
    required this.matchSetup,
    required this.leftPlayerName,
    required this.rightPlayerName,
    required this.startedAt,
    required this.leftPlayers,
    required this.rightPlayers,
  });

  @override
  State<ScoreboardPage> createState() => _ScoreboardPageState();
}

class _ScoreboardPageState extends State<ScoreboardPage> {
  static const int _dominoTargetScore = 101;

  int _leftScore = 0;
  int _rightScore = 0;
  int _selectedSet = 1;
  late int _setCount;
  Timer? _ticker;
  DateTime? _matchFinishedAt;
  final TextEditingController _leftDominoInputController =
      TextEditingController();
  final TextEditingController _rightDominoInputController =
      TextEditingController();

  final List<ScoreHistoryItem> _history = [];
  final Map<int, _SetScore> _setScores = {1: const _SetScore(leftScore: 0, rightScore: 0)};
  final Map<int, bool> _setWinners = {};
  final Map<int, Duration> _setDurations = {};
  final Map<int, DateTime> _setStartedAt = {};

  static const Color _leftPlayerColor = Color(0xFFFE7F2D);
  static const Color _rightPlayerColor = Color(0xFF009DFF);

  bool get _isSetMode => widget.matchSetup.scoringSystem == 'Set';
  bool get _usesSetTracking => _isSetMode || _isDomino;

  bool get _usesTennisSequence {
    final sportName = widget.matchSetup.sport.name.toLowerCase();
    return (sportName.contains('tenis') && !sportName.contains('tenis meja')) ||
        sportName.contains('padel');
  }

  bool get _isBadminton {
    final sportName = widget.matchSetup.sport.name.toLowerCase();
    return sportName.contains('badminton');
  }

  bool get _isTableTennis {
    final sportName = widget.matchSetup.sport.name.toLowerCase();
    return sportName.contains('tenis meja');
  }

  bool get _isDomino {
    final sportName = widget.matchSetup.sport.name.toLowerCase();
    return sportName.contains('domino');
  }

  bool get _isDominoResetMode =>
      _isDomino &&
      widget.matchSetup.dominoScoreMode.toLowerCase().contains('reset');

  bool get _canSetPoint {
    if (_setWinners.containsKey(_selectedSet)) {
      return false;
    }

    if (_isBadminton) {
      return _isBadmintonSetWinner(_leftScore, _rightScore) ||
          _isBadmintonSetWinner(_rightScore, _leftScore);
    }

    if (_isTableTennis) {
      return _isTableTennisSetWinner(_leftScore, _rightScore) ||
          _isTableTennisSetWinner(_rightScore, _leftScore);
    }

    if (!_usesTennisSequence) {
      return false;
    }

    final hasAdvantage = _leftScore >= 4 || _rightScore >= 4;
    if (hasAdvantage) {
      return true;
    }

    final isDeuce = _leftScore == 3 && _rightScore == 3;
    if (isDeuce) {
      return false;
    }

    final hasForty = _leftScore == 3 || _rightScore == 3;
    return hasForty;
  }

  bool _isBadmintonSetWinner(int score, int opponentScore) {
    if (score >= 30) {
      return true;
    }

    if (score < 21) {
      return false;
    }

    return score - opponentScore >= 2;
  }

  bool _isTableTennisSetWinner(int score, int opponentScore) {
    if (score < 11) {
      return false;
    }

    return score - opponentScore >= 2;
  }

  @override
  void initState() {
    super.initState();
    final target = widget.matchSetup.targetSets ?? 0;
    _setCount = _usesSetTracking ? (target < 2 ? 2 : target) : 1;
    _setStartedAt[1] = widget.startedAt;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _matchFinishedAt != null) {
        _ticker?.cancel();
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _leftDominoInputController.dispose();
    _rightDominoInputController.dispose();
    super.dispose();
  }

  List<ScoreHistoryItem> get _visibleHistory {
    if (!_usesSetTracking) {
      return _history;
    }
    return _history.where((item) => item.setNumber == _selectedSet).toList();
  }

  int get _leftSetWins => _setWinners.values.where((winner) => winner).length;
  int get _rightSetWins => _setWinners.values.where((winner) => !winner).length;

  Duration get _matchDuration =>
      (_matchFinishedAt ?? DateTime.now()).difference(widget.startedAt);

  bool get _hasMatchWinner => _leftSetWins != _rightSetWins;

  bool get _canFinalizeMatch =>
      _matchFinishedAt == null &&
      _usesSetTracking &&
      _isMatchFinished &&
      _hasMatchWinner;

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    final twoDigitMinutes = minutes.toString().padLeft(2, '0');
    final twoDigitSeconds = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$twoDigitMinutes:$twoDigitSeconds';
    }

    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  Duration _setDurationFor(int setNumber) {
    final finishedDuration = _setDurations[setNumber];
    if (finishedDuration != null) {
      return finishedDuration;
    }

    final startedAt = _setStartedAt[setNumber];
    if (startedAt == null) {
      return Duration.zero;
    }

    final endTime = _matchFinishedAt ?? DateTime.now();
    return endTime.difference(startedAt);
  }

  String _scoreText(int score) {
    if (_isDomino || !_usesTennisSequence) {
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

  int _parseDominoInput(TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isEmpty) {
      return 0;
    }

    return int.tryParse(text) ?? -1;
  }

  void _persistCurrentSetScore() {
    _setScores[_selectedSet] = _SetScore(
      leftScore: _leftScore,
      rightScore: _rightScore,
    );
  }

  void _loadSetScore(int setNumber) {
    final setScore = _setScores[setNumber] ??
        const _SetScore(leftScore: 0, rightScore: 0);
    _leftScore = setScore.leftScore;
    _rightScore = setScore.rightScore;
  }

  void _completeCurrentSet({required bool leftWins, required String note}) {
    final now = DateTime.now();
    _persistCurrentSetScore();
    _setWinners[_selectedSet] = leftWins;
    _setDurations[_selectedSet] = now.difference(
      _setStartedAt[_selectedSet] ?? widget.startedAt,
    );
    _appendHistory(note);

    final nextSet = _selectedSet + 1;
    if (nextSet <= _setCount) {
      _setStartedAt.putIfAbsent(nextSet, () => now);
      _setScores.putIfAbsent(
        nextSet,
        () => const _SetScore(leftScore: 0, rightScore: 0),
      );
      _selectedSet = nextSet;
      _loadSetScore(nextSet);
    }
  }

  void _applyDominoRoundScore() {
    if (_matchFinishedAt != null || _setWinners.containsKey(_selectedSet)) {
      return;
    }

    final leftAdded = _parseDominoInput(_leftDominoInputController);
    final rightAdded = _parseDominoInput(_rightDominoInputController);

    if (leftAdded < 0 || rightAdded < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan angka yang valid untuk skor domino.')),
      );
      return;
    }

    final hasLeftInput = leftAdded > 0;
    final hasRightInput = rightAdded > 0;

    if (hasLeftInput == hasRightInput) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan skor hanya untuk tim yang kalah pada ronde ini.'),
        ),
      );
      return;
    }

    setState(() {
      if (hasLeftInput) {
        final previousRightScore = _rightScore;
        final nextLeftScore = (_leftScore + leftAdded).clamp(0, _dominoTargetScore);
        final shouldResetRight = _isDominoResetMode && nextLeftScore > previousRightScore;

        _leftScore = nextLeftScore;
        if (shouldResetRight) {
          _rightScore = 0;
        }
        _persistCurrentSetScore();
        _appendHistory(
          shouldResetRight
              ? '${widget.leftPlayerName} +$leftAdded (reset ${widget.rightPlayerName})'
              : '${widget.leftPlayerName} +$leftAdded',
        );
      } else {
        final previousLeftScore = _leftScore;
        final nextRightScore = (_rightScore + rightAdded).clamp(0, _dominoTargetScore);
        final shouldResetLeft = _isDominoResetMode && nextRightScore > previousLeftScore;

        _rightScore = nextRightScore;
        if (shouldResetLeft) {
          _leftScore = 0;
        }
        _persistCurrentSetScore();
        _appendHistory(
          shouldResetLeft
              ? '${widget.rightPlayerName} +$rightAdded (reset ${widget.leftPlayerName})'
              : '${widget.rightPlayerName} +$rightAdded',
        );
      }

      final leftReachedTarget = _leftScore >= _dominoTargetScore;
      final rightReachedTarget = _rightScore >= _dominoTargetScore;

      if (leftReachedTarget || rightReachedTarget) {
        _completeCurrentSet(
          leftWins: rightReachedTarget,
          note:
              'Set $_selectedSet dimenangkan ${rightReachedTarget ? widget.leftPlayerName : widget.rightPlayerName}',
        );
      }

      _leftDominoInputController.clear();
      _rightDominoInputController.clear();
    });
  }

  bool _applyScoreChange({required bool left, required int delta}) {
    if (delta == 0) {
      return false;
    }

    if (!_usesTennisSequence) {
      if (left) {
        final next = (_leftScore + delta).clamp(0, 999);
        if (next == _leftScore) {
          return false;
        }
        _leftScore = next;
        return true;
      }

      final next = (_rightScore + delta).clamp(0, 999);
      if (next == _rightScore) {
        return false;
      }
      _rightScore = next;
      return true;
    }

    int own = left ? _leftScore : _rightScore;
    int opp = left ? _rightScore : _leftScore;

    if (delta > 0) {
      if (own < 3) {
        own += 1;
      } else if (own == 3 && opp == 3) {
        own = 4;
      } else if (opp == 4) {
        opp = 3;
      } else {
        return false;
      }
    } else {
      if (own == 4) {
        own = 3;
      } else if (own > 0) {
        own -= 1;
      } else {
        return false;
      }
    }

    if (left) {
      _leftScore = own;
      _rightScore = opp;
    } else {
      _rightScore = own;
      _leftScore = opp;
    }

    _persistCurrentSetScore();

    return true;
  }

  void _appendHistory(String note) {
    _history.insert(
      0,
      ScoreHistoryItem(
        leftScore: _leftScore,
        rightScore: _rightScore,
        note: note,
        setNumber: _usesSetTracking ? _selectedSet : null,
      ),
    );
  }

  void _changeLeftScore(int delta) {
    setState(() {
      final changed = _applyScoreChange(left: true, delta: delta);
      if (!changed) {
        return;
      }
      _appendHistory(
        delta > 0
            ? '${widget.leftPlayerName} +1'
            : '${widget.leftPlayerName} -1',
      );
    });
  }

  void _changeRightScore(int delta) {
    setState(() {
      final changed = _applyScoreChange(left: false, delta: delta);
      if (!changed) {
        return;
      }
      _appendHistory(
        delta > 0
            ? '${widget.rightPlayerName} +1'
            : '${widget.rightPlayerName} -1',
      );
    });
  }

  void _setPoint() {
    if (!_canSetPoint) {
      return;
    }

    if (_leftScore == _rightScore) {
      return;
    }

    setState(() {
      final leftWins = _leftScore > _rightScore;
      _completeCurrentSet(
        leftWins: leftWins,
        note:
            'Set $_selectedSet dimenangkan ${leftWins ? widget.leftPlayerName : widget.rightPlayerName}',
      );
    });
  }

  bool get _isMatchFinished {
    if (!_usesSetTracking) {
      return false;
    }
    return _setWinners.length >= _setCount;
  }

  void _addCustomSet() {
    if (!_usesSetTracking) {
      return;
    }

    setState(() {
      _setCount += 1;
      _setScores.putIfAbsent(
        _setCount,
        () => const _SetScore(leftScore: 0, rightScore: 0),
      );
    });
  }

  void _finishMatch() {
    if (!_canFinalizeMatch) {
      return;
    }

    final leftWon = _leftSetWins > _rightSetWins;
    final result = MatchResult(
      winnerNames: leftWon ? widget.leftPlayers : widget.rightPlayers,
      loserNames: leftWon ? widget.rightPlayers : widget.leftPlayers,
    );

    showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          surfaceTintColor: backgroundColor,
          title: const Text(
            'Selesaikan pertandingan?',
            style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
          ),
          content: Text(
            _isDomino
                ? 'Skor akhir ${widget.leftPlayerName} $_leftScore - $_rightScore ${widget.rightPlayerName}. Setelah dikonfirmasi, timer pertandingan akan berhenti.'
                : 'Durasi total pertandingan ${_formatDuration(_matchDuration)}. Setelah dikonfirmasi, timer pertandingan akan berhenti.',
            style: const TextStyle(color: textColor, height: 1.4),
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
    ).then((shouldFinish) {
      if (shouldFinish != true || !mounted) {
        return;
      }

      setState(() {
        _matchFinishedAt = DateTime.now();
      });
      _ticker?.cancel();
      Navigator.of(context).pop(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.matchSetup.sport.gradientColors[0];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        titleSpacing: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Scoreboard',
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
                MatchSummaryCard(
                  title: widget.matchSetup.matchName,
                  durationText: _formatDuration(_matchDuration),
                  gradientColors: widget.matchSetup.sport.gradientColors,
                ),

                if (_usesSetTracking) ...[
                  const SizedBox(height: 12),
                  SetScoreSummary(
                    leftSetWins: _leftSetWins,
                    rightSetWins: _rightSetWins,
                    cardColor: accentColor,
                  ),
                ],
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: PlayerScoreCard(
                        playerName: widget.leftPlayerName,
                        scoreText: _scoreText(_leftScore),
                        backgroundColor: _leftPlayerColor,
                        onDecrease: (_isDomino || _setWinners.containsKey(_selectedSet))
                          ? null
                          : () => _changeLeftScore(-1),
                        onIncrease: (_isDomino || _setWinners.containsKey(_selectedSet))
                          ? null
                          : () => _changeLeftScore(1),
                        footer: _isDomino
                            ? TextField(
                                controller: _leftDominoInputController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                            enabled: _matchFinishedAt == null &&
                              !_setWinners.containsKey(_selectedSet),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Input angka',
                                  hintStyle: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                  filled: true,
                                  // ignore: deprecated_member_use
                                  fillColor: Colors.white.withOpacity(0.14),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PlayerScoreCard(
                        playerName: widget.rightPlayerName,
                        scoreText: _scoreText(_rightScore),
                        backgroundColor: _rightPlayerColor,
                        onDecrease: (_isDomino || _setWinners.containsKey(_selectedSet))
                          ? null
                          : () => _changeRightScore(-1),
                        onIncrease: (_isDomino || _setWinners.containsKey(_selectedSet))
                          ? null
                          : () => _changeRightScore(1),
                        footer: _isDomino
                            ? TextField(
                                controller: _rightDominoInputController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                            enabled: _matchFinishedAt == null &&
                              !_setWinners.containsKey(_selectedSet),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Input angka',
                                  hintStyle: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                  filled: true,
                                  // ignore: deprecated_member_use
                                  fillColor: Colors.white.withOpacity(0.14),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isDomino
                        ? (_matchFinishedAt == null ? _applyDominoRoundScore : null)
                        : (_canSetPoint ? _setPoint : null),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade800,
                      disabledForegroundColor: Colors.grey.shade300,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _isDomino ? 'Simpan Skor Ronde' : 'Set Point',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                if (_isDomino) ...[
                  const SizedBox(height: 10),
                  Text(
                    _setWinners.containsKey(_selectedSet)
                        ? 'Set ini sudah selesai. Pindah ke set lain atau tambah set baru jika diperlukan.'
                        : (_isDominoResetMode
                              ? 'Mode Reset Angka aktif. Saat Anda input skor untuk satu tim, skor tim lawan otomatis kembali ke 0, lalu skor baru ditambahkan. Tim yang mencapai 101 dinyatakan kalah.'
                              : 'Skor dimulai dari 0 - 0. Isi angka tim yang kalah pada ronde ini, lalu skor akan otomatis ditambahkan ke total sebelumnya. Tim yang mencapai 101 dinyatakan kalah.'),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                if (_usesSetTracking) ...[
                  SetSelector(
                    setCount: _setCount,
                    selectedSet: _selectedSet,
                    setWinners: _setWinners,
                    leftPlayerColor: _leftPlayerColor,
                    rightPlayerColor: _rightPlayerColor,
                    accentColor: accentColor,
                    onAddSet: _addCustomSet,
                    onSelectSet: (setNumber) {
                      setState(() {
                        _setStartedAt.putIfAbsent(
                          setNumber,
                          () => DateTime.now(),
                        );
                        _setScores.putIfAbsent(
                          setNumber,
                          () => const _SetScore(leftScore: 0, rightScore: 0),
                        );
                        _selectedSet = setNumber;
                        _loadSetScore(setNumber);
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                ],
                ScoreHistorySection(
                  isSetMode: _usesSetTracking,
                  selectedSet: _selectedSet,
                  hasSetTimer: _setStartedAt.containsKey(_selectedSet),
                  setDurationText: _formatDuration(
                    _setDurationFor(_selectedSet),
                  ),
                  accentColor: accentColor,
                  leftPlayerName: widget.leftPlayerName,
                  rightPlayerName: widget.rightPlayerName,
                  leftPlayerColor: _leftPlayerColor,
                  rightPlayerColor: _rightPlayerColor,
                  items: _visibleHistory,
                  scoreTextBuilder: _scoreText,
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
                  onPressed: _canFinalizeMatch ? _finishMatch : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
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
                    'Pertandingan Selesai',
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
