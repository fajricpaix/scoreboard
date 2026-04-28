import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scoreboard/components/create/create_background.dart';
import 'package:scoreboard/components/create/models.dart';
import 'package:scoreboard/components/scoreboard/models.dart';
import 'package:scoreboard/components/scoreboard/scoreboard_domino_input.dart';
import 'package:scoreboard/components/scoreboard/scoreboard_footer_section.dart';
import 'package:scoreboard/components/scoreboard/scoreboard_header_section.dart';
import 'package:scoreboard/components/scoreboard/scoreboard_player_scores_section.dart';
import 'package:scoreboard/components/scoreboard/scoreboard_primary_action_section.dart';
import 'package:scoreboard/components/scoreboard/scoreboard_rules.dart';
import 'package:scoreboard/components/scoreboard/scoreboard_sets_history_section.dart';
import 'package:scoreboard/theme/index.dart';

class ScoreboardPageContent extends StatefulWidget {
  final MatchSetup matchSetup;
  final String leftPlayerName;
  final String rightPlayerName;
  final DateTime startedAt;
  final List<String> leftPlayers;
  final List<String> rightPlayers;

  const ScoreboardPageContent({
    super.key,
    required this.matchSetup,
    required this.leftPlayerName,
    required this.rightPlayerName,
    required this.startedAt,
    required this.leftPlayers,
    required this.rightPlayers,
  });

  @override
  State<ScoreboardPageContent> createState() => _ScoreboardPageContentState();
}

class _SetScore {
  final int leftScore;
  final int rightScore;

  const _SetScore({required this.leftScore, required this.rightScore});
}

class _ScoreboardPageContentState extends State<ScoreboardPageContent> {
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
  final Map<int, _SetScore> _setScores = {
    1: const _SetScore(leftScore: 0, rightScore: 0),
  };
  final Map<int, bool> _setWinners = {};
  final Map<int, Duration> _setDurations = {};
  final Map<int, DateTime> _setStartedAt = {};

  static const Color _leftPlayerColor = Color(0xFFFE7F2D);
  static const Color _rightPlayerColor = Color(0xFF009DFF);

  String get _sportNameLower => widget.matchSetup.sport.name.toLowerCase();

  bool get _isSetMode => widget.matchSetup.scoringSystem == 'Set';
  bool get _usesSetTracking => _isSetMode || _isDomino;

  bool get _usesTennisSequence {
    return ScoreboardRules.usesTennisSequence(_sportNameLower);
  }

  bool get _isBadminton {
    return ScoreboardRules.isBadminton(_sportNameLower);
  }

  bool get _isTableTennis {
    return ScoreboardRules.isTableTennis(_sportNameLower);
  }

  bool get _isDomino {
    return ScoreboardRules.isDomino(_sportNameLower);
  }

  bool get _isDominoResetMode =>
      _isDomino &&
      widget.matchSetup.dominoScoreMode.toLowerCase().contains('reset');

  bool get _isCurrentSetLocked =>
      _matchFinishedAt != null || _setWinners.containsKey(_selectedSet);

  Color get _accentColor => widget.matchSetup.sport.gradientColors[0];

  bool get _canSetPoint {
    return ScoreboardRules.canSetPoint(
      leftScore: _leftScore,
      rightScore: _rightScore,
      setAlreadyWon: _setWinners.containsKey(_selectedSet),
      isBadminton: _isBadminton,
      isTableTennis: _isTableTennis,
      usesTennisSequence: _usesTennisSequence,
    );
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
    return ScoreboardRules.scoreText(
      score: score,
      isDomino: _isDomino,
      usesTennisSequence: _usesTennisSequence,
    );
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
    final setScore =
        _setScores[setNumber] ?? const _SetScore(leftScore: 0, rightScore: 0);
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
        const SnackBar(
          content: Text('Masukkan angka yang valid untuk skor domino.'),
        ),
      );
      return;
    }

    final hasLeftInput = leftAdded > 0;
    final hasRightInput = rightAdded > 0;

    if (hasLeftInput == hasRightInput) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Masukkan skor hanya untuk tim yang kalah pada ronde ini.',
          ),
        ),
      );
      return;
    }

    setState(() {
      if (hasLeftInput) {
        final previousRightScore = _rightScore;
        final nextLeftScore = (_leftScore + leftAdded).clamp(
          0,
          _dominoTargetScore,
        );
        final shouldResetRight =
            _isDominoResetMode && nextLeftScore > previousRightScore;

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
        final nextRightScore = (_rightScore + rightAdded).clamp(
          0,
          _dominoTargetScore,
        );
        final shouldResetLeft =
            _isDominoResetMode && nextRightScore > previousLeftScore;

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
                : 'Durasi total pertandingan ${ScoreboardRules.formatDuration(_matchDuration)}. Setelah dikonfirmasi, timer pertandingan akan berhenti.',
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

  String? get _dominoHelperText {
    return ScoreboardRules.dominoHelperText(
      isDomino: _isDomino,
      setAlreadyWon: _setWinners.containsKey(_selectedSet),
      isDominoResetMode: _isDominoResetMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: _accentColor,
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
      body: CreateBackground(
        imageOpacity: 0.5,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                children: [
                  ScoreboardHeaderSection(
                    title: widget.matchSetup.matchName,
                    durationText: ScoreboardRules.formatDuration(
                      _matchDuration,
                    ),
                    gradientColors: widget.matchSetup.sport.gradientColors,
                    usesSetTracking: _usesSetTracking,
                    leftSetWins: _leftSetWins,
                    rightSetWins: _rightSetWins,
                    accentColor: _accentColor,
                  ),
                  const SizedBox(height: 12),
                  ScoreboardPlayerScoresSection(
                    leftPlayerName: widget.leftPlayerName,
                    rightPlayerName: widget.rightPlayerName,
                    leftScoreText: _scoreText(_leftScore),
                    rightScoreText: _scoreText(_rightScore),
                    leftPlayerColor: _leftPlayerColor,
                    rightPlayerColor: _rightPlayerColor,
                    onLeftDecrease: (_isDomino || _isCurrentSetLocked)
                        ? null
                        : () => _changeLeftScore(-1),
                    onLeftIncrease: (_isDomino || _isCurrentSetLocked)
                        ? null
                        : () => _changeLeftScore(1),
                    onRightDecrease: (_isDomino || _isCurrentSetLocked)
                        ? null
                        : () => _changeRightScore(-1),
                    onRightIncrease: (_isDomino || _isCurrentSetLocked)
                        ? null
                        : () => _changeRightScore(1),
                    leftFooter: _isDomino
                        ? ScoreboardDominoInput(
                            controller: _leftDominoInputController,
                            enabled: !_isCurrentSetLocked,
                          )
                        : null,
                    rightFooter: _isDomino
                        ? ScoreboardDominoInput(
                            controller: _rightDominoInputController,
                            enabled: !_isCurrentSetLocked,
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  ScoreboardPrimaryActionSection(
                    onPressed: _isDomino
                        ? (_matchFinishedAt == null
                              ? _applyDominoRoundScore
                              : null)
                        : (_canSetPoint ? _setPoint : null),
                    accentColor: _accentColor,
                    buttonLabel: _isDomino ? 'Simpan Skor Ronde' : 'Set Point',
                    helperText: _dominoHelperText,
                  ),
                  const SizedBox(height: 20),
                  ScoreboardSetsHistorySection(
                    usesSetTracking: _usesSetTracking,
                    setCount: _setCount,
                    selectedSet: _selectedSet,
                    setWinners: _setWinners,
                    leftPlayerColor: _leftPlayerColor,
                    rightPlayerColor: _rightPlayerColor,
                    accentColor: _accentColor,
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
                    hasSetTimer: _setStartedAt.containsKey(_selectedSet),
                    setDurationText: ScoreboardRules.formatDuration(
                      _setDurationFor(_selectedSet),
                    ),
                    leftPlayerName: widget.leftPlayerName,
                    rightPlayerName: widget.rightPlayerName,
                    items: _visibleHistory,
                    scoreTextBuilder: _scoreText,
                  ),
                ],
              ),
            ),
            ScoreboardFooterSection(
              canFinalizeMatch: _canFinalizeMatch,
              accentColor: _accentColor,
              onFinishMatch: _finishMatch,
            ),
          ],
        ),
      ),
    );
  }
}
