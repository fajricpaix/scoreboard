import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scoreboard/components/create/models.dart';
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

class _ScoreHistoryItem {
  final int leftScore;
  final int rightScore;
  final String note;
  final int? setNumber;

  const _ScoreHistoryItem({
    required this.leftScore,
    required this.rightScore,
    required this.note,
    this.setNumber,
  });
}

class _ScoreboardPageState extends State<ScoreboardPage> {
  int _leftScore = 0;
  int _rightScore = 0;
  int _selectedSet = 1;
  late int _setCount;
  Timer? _ticker;
  DateTime? _matchFinishedAt;

  final List<_ScoreHistoryItem> _history = [];
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

  bool get _canSetPoint {
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

  @override
  void initState() {
    super.initState();
    final target = widget.matchSetup.targetSets ?? 0;
    _setCount = _isSetMode ? (target < 4 ? 4 : target) : 1;
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

  List<_ScoreHistoryItem> get _visibleHistory {
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
      _ScoreHistoryItem(
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

  Widget _scoreActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 32,
      height: 32,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: textColor,
          padding: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.matchSetup.sport.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.matchSetup.matchName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Text(
                            'Durasi : ',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatDuration(_matchDuration),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Set Scoreboard
                if (_isSetMode) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: widget.matchSetup.sport.gradientColors[0],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$_leftSetWins',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ':',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: textColor,
                          fontSize: 36,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: widget.matchSetup.sport.gradientColors[0],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$_rightSetWins',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),

                // Scoreboard
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: _leftPlayerColor,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.leftPlayerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _scoreText(_leftScore),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 38,
                                fontWeight: FontWeight.w800,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _scoreActionButton(
                                  icon: Icons.remove,
                                  onTap: () => _changeLeftScore(-1),
                                ),
                                const SizedBox(width: 8),
                                _scoreActionButton(
                                  icon: Icons.add,
                                  onTap: () => _changeLeftScore(1),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: _rightPlayerColor,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.rightPlayerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _scoreText(_rightScore),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 38,
                                fontWeight: FontWeight.w800,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _scoreActionButton(
                                  icon: Icons.remove,
                                  onTap: () => _changeRightScore(-1),
                                ),
                                const SizedBox(width: 8),
                                _scoreActionButton(
                                  icon: Icons.add,
                                  onTap: () => _changeRightScore(1),
                                ),
                              ],
                            ),
                          ],
                        ),
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
                      backgroundColor:
                          widget.matchSetup.sport.gradientColors[0],
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

                // History Scoreboard
                if (_isSetMode) ...[
                  SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _setCount + 1,
                      itemBuilder: (context, index) {
                        if (index == _setCount) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: SizedBox(
                              width: 38,
                              child: OutlinedButton(
                                onPressed: _addCustomSet,
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  backgroundColor: Colors.white,
                                  foregroundColor:
                                      widget.matchSetup.sport.gradientColors[0],
                                  side: BorderSide(
                                    color: widget
                                        .matchSetup
                                        .sport
                                        .gradientColors[0],
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Icon(Icons.add, size: 18),
                              ),
                            ),
                          );
                        }

                        final setNumber = index + 1;
                        final selected = setNumber == _selectedSet;
                        final setWinner = _setWinners[setNumber];
                        final hasWinner = setWinner != null;
                        final winnerColor = setWinner == true
                            ? _leftPlayerColor
                            : _rightPlayerColor;
                        final backgroundColor = hasWinner
                            ? winnerColor
                            : (selected
                                  ? widget.matchSetup.sport.gradientColors[0]
                                  : Colors.white);
                        final foregroundColor = hasWinner || selected
                            ? Colors.white
                            : textColor;
                        final borderColor = hasWinner
                            ? winnerColor
                            : widget.matchSetup.sport.gradientColors[0];

                        return Padding(
                          padding: EdgeInsets.only(
                            right: index == _setCount - 1 ? 0 : 8,
                          ),
                          child: OutlinedButton(
                            onPressed: () {
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
                            style: OutlinedButton.styleFrom(
                              backgroundColor: backgroundColor,
                              foregroundColor: foregroundColor,
                              side: BorderSide(color: borderColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Set $setNumber',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                const Text(
                  'Riwayat Set',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                if (_isSetMode)
                  Container(
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: widget.matchSetup.sport.gradientColors[0]
                                .withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Set $_selectedSet',
                            style: TextStyle(
                              color: widget.matchSetup.sport.gradientColors[0],
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Durasi ${_setStartedAt.containsKey(_selectedSet) ? _formatDuration(_setDurationFor(_selectedSet)) : '--:--'}',
                            style: const TextStyle(
                              color: textColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_visibleHistory.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: const Text(
                      'Belum ada riwayat skor.',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ),
                if (_visibleHistory.isNotEmpty)
                  ..._visibleHistory.map((item) {
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
                          Text(
                            '${_scoreText(item.leftScore)} - ${_scoreText(item.rightScore)}',
                            style: const TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.note,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
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
                  onPressed: _canFinalizeMatch ? _finishMatch : null,
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
