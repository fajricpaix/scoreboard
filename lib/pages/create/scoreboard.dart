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
  int _leftScore = 0;
  int _rightScore = 0;
  int _selectedSet = 1;
  late int _setCount;
  Timer? _ticker;
  DateTime? _matchFinishedAt;

  final List<ScoreHistoryItem> _history = [];
  final Map<int, bool> _setWinners = {};
  final Map<int, Duration> _setDurations = {};
  final Map<int, DateTime> _setStartedAt = {};

  static const Color _leftPlayerColor = Color(0xFFFE7F2D);
  static const Color _rightPlayerColor = Color(0xFF233D4D);

  bool get _isSetMode => widget.matchSetup.scoringSystem == 'Set';

  bool get _usesTennisSequence {
    final sportName = widget.matchSetup.sport.name.toLowerCase();
    return sportName.contains('tenis') || sportName.contains('padel');
  }

  bool get _isBadminton {
    final sportName = widget.matchSetup.sport.name.toLowerCase();
    return sportName.contains('badminton');
  }

  bool get _canSetPoint {
    if (_isBadminton) {
      return _isBadmintonSetWinner(_leftScore, _rightScore) ||
          _isBadmintonSetWinner(_rightScore, _leftScore);
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

  @override
  void initState() {
    super.initState();
    final target = widget.matchSetup.targetSets ?? 0;
    _setCount = _isSetMode ? (target < 2 ? 2 : target) : 1;
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
    super.dispose();
  }

  List<ScoreHistoryItem> get _visibleHistory {
    if (!_isSetMode) {
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
      _isMatchFinished && _matchFinishedAt == null && _hasMatchWinner;

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

    return true;
  }

  void _appendHistory(String note) {
    _history.insert(
      0,
      ScoreHistoryItem(
        leftScore: _leftScore,
        rightScore: _rightScore,
        note: note,
        setNumber: _isSetMode ? _selectedSet : null,
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
      final now = DateTime.now();
      final leftWins = _leftScore > _rightScore;
      _setWinners[_selectedSet] = leftWins;
      _setDurations[_selectedSet] = now.difference(
        _setStartedAt[_selectedSet] ?? widget.startedAt,
      );
      _setStartedAt.putIfAbsent(_selectedSet + 1, () => now);
      _appendHistory(
        'Set $_selectedSet dimenangkan ${leftWins ? widget.leftPlayerName : widget.rightPlayerName}',
      );
    });
  }

  bool get _isMatchFinished {
    if (!_isSetMode) {
      return false;
    }
    return _setWinners.length >= _setCount;
  }

  void _addCustomSet() {
    if (!_isSetMode) {
      return;
    }

    setState(() {
      _setCount += 1;
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
            'Durasi total pertandingan ${_formatDuration(_matchDuration)}. Setelah dikonfirmasi, timer pertandingan akan berhenti.',
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

                if (_isSetMode) ...[
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
                        onDecrease: () => _changeLeftScore(-1),
                        onIncrease: () => _changeLeftScore(1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PlayerScoreCard(
                        playerName: widget.rightPlayerName,
                        scoreText: _scoreText(_rightScore),
                        backgroundColor: _rightPlayerColor,
                        onDecrease: () => _changeRightScore(-1),
                        onIncrease: () => _changeRightScore(1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canSetPoint ? _setPoint : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.grey.shade600,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Set Point',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                if (_isSetMode) ...[
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
                        if (_selectedSet != setNumber) {
                          _leftScore = 0;
                          _rightScore = 0;
                        }
                        _setStartedAt.putIfAbsent(
                          setNumber,
                          () => DateTime.now(),
                        );
                        _selectedSet = setNumber;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                ],
                ScoreHistorySection(
                  isSetMode: _isSetMode,
                  selectedSet: _selectedSet,
                  hasSetTimer: _setStartedAt.containsKey(_selectedSet),
                  setDurationText: _formatDuration(
                    _setDurationFor(_selectedSet),
                  ),
                  accentColor: accentColor,
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
