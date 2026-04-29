import 'dart:collection';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:scoreboard/components/scoreboard/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MatchSetRecord {
  final int setNumber;
  final int leftScore;
  final int rightScore;
  final bool? leftWon;

  const MatchSetRecord({
    required this.setNumber,
    required this.leftScore,
    required this.rightScore,
    this.leftWon,
  });

  Map<String, dynamic> toJson() {
    return {
      'setNumber': setNumber,
      'leftScore': leftScore,
      'rightScore': rightScore,
      'leftWon': leftWon,
    };
  }

  factory MatchSetRecord.fromJson(Map<String, dynamic> json) {
    return MatchSetRecord(
      setNumber: json['setNumber'] as int? ?? 0,
      leftScore: json['leftScore'] as int? ?? 0,
      rightScore: json['rightScore'] as int? ?? 0,
      leftWon: json['leftWon'] as bool?,
    );
  }
}

class MatchScoreHistoryRecord {
  final int leftScore;
  final int rightScore;
  final String note;
  final int? setNumber;

  const MatchScoreHistoryRecord({
    required this.leftScore,
    required this.rightScore,
    required this.note,
    required this.setNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'leftScore': leftScore,
      'rightScore': rightScore,
      'note': note,
      'setNumber': setNumber,
    };
  }

  factory MatchScoreHistoryRecord.fromJson(Map<String, dynamic> json) {
    return MatchScoreHistoryRecord(
      leftScore: json['leftScore'] as int? ?? 0,
      rightScore: json['rightScore'] as int? ?? 0,
      note: json['note'] as String? ?? '-',
      setNumber: json['setNumber'] as int?,
    );
  }

  factory MatchScoreHistoryRecord.fromScoreHistoryItem(ScoreHistoryItem item) {
    return MatchScoreHistoryRecord(
      leftScore: item.leftScore,
      rightScore: item.rightScore,
      note: item.note,
      setNumber: item.setNumber,
    );
  }
}

class MatchHistoryRecord {
  final String id;
  final String sport;
  final String matchName;
  final String gameType;
  final String scoringSystem;
  final String dominoScoreMode;
  final DateTime startedAt;
  final DateTime finishedAt;
  final String leftPlayerName;
  final String rightPlayerName;
  final List<String> leftPlayers;
  final List<String> rightPlayers;
  final List<String> winnerNames;
  final List<String> loserNames;
  final int leftSummaryScore;
  final int rightSummaryScore;
  final List<MatchSetRecord> sets;
  final List<MatchScoreHistoryRecord> scoreHistory;

  const MatchHistoryRecord({
    required this.id,
    required this.sport,
    required this.matchName,
    required this.gameType,
    required this.scoringSystem,
    required this.dominoScoreMode,
    required this.startedAt,
    required this.finishedAt,
    required this.leftPlayerName,
    required this.rightPlayerName,
    required this.leftPlayers,
    required this.rightPlayers,
    required this.winnerNames,
    required this.loserNames,
    required this.leftSummaryScore,
    required this.rightSummaryScore,
    required this.sets,
    required this.scoreHistory,
  });

  bool get isDraw => winnerNames.isEmpty;

  Duration get duration => finishedAt.difference(startedAt);

  String get playerLabel => '$leftPlayerName vs $rightPlayerName';

  String get winnerLabel {
    if (isDraw) {
      return 'Seri';
    }
    return winnerNames.join(' / ');
  }

  String get scoreLabel => '$leftSummaryScore-$rightSummaryScore';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sport': sport,
      'matchName': matchName,
      'gameType': gameType,
      'scoringSystem': scoringSystem,
      'dominoScoreMode': dominoScoreMode,
      'startedAt': startedAt.toIso8601String(),
      'finishedAt': finishedAt.toIso8601String(),
      'leftPlayerName': leftPlayerName,
      'rightPlayerName': rightPlayerName,
      'leftPlayers': leftPlayers,
      'rightPlayers': rightPlayers,
      'winnerNames': winnerNames,
      'loserNames': loserNames,
      'leftSummaryScore': leftSummaryScore,
      'rightSummaryScore': rightSummaryScore,
      'sets': sets.map((item) => item.toJson()).toList(),
      'scoreHistory': scoreHistory.map((item) => item.toJson()).toList(),
    };
  }

  factory MatchHistoryRecord.fromJson(Map<String, dynamic> json) {
    return MatchHistoryRecord(
      id: json['id'] as String? ?? '',
      sport: json['sport'] as String? ?? '-',
      matchName: json['matchName'] as String? ?? '-',
      gameType: json['gameType'] as String? ?? '-',
      scoringSystem: json['scoringSystem'] as String? ?? '-',
      dominoScoreMode: json['dominoScoreMode'] as String? ?? '-',
      startedAt:
          DateTime.tryParse(json['startedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      finishedAt:
          DateTime.tryParse(json['finishedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      leftPlayerName: json['leftPlayerName'] as String? ?? '-',
      rightPlayerName: json['rightPlayerName'] as String? ?? '-',
      leftPlayers: (json['leftPlayers'] as List<dynamic>? ?? const [])
          .map((item) => item as String)
          .toList(),
      rightPlayers: (json['rightPlayers'] as List<dynamic>? ?? const [])
          .map((item) => item as String)
          .toList(),
      winnerNames: (json['winnerNames'] as List<dynamic>? ?? const [])
          .map((item) => item as String)
          .toList(),
      loserNames: (json['loserNames'] as List<dynamic>? ?? const [])
          .map((item) => item as String)
          .toList(),
      leftSummaryScore: json['leftSummaryScore'] as int? ?? 0,
      rightSummaryScore: json['rightSummaryScore'] as int? ?? 0,
      sets: (json['sets'] as List<dynamic>? ?? const [])
          .map((item) => MatchSetRecord.fromJson(item as Map<String, dynamic>))
          .toList(),
      scoreHistory: (json['scoreHistory'] as List<dynamic>? ?? const [])
          .map(
            (item) =>
                MatchScoreHistoryRecord.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class MatchHistoryService {
  static const String _storageKey = 'match_history_records_v1';
  static const int _maxStoredPerSport = 5;

  const MatchHistoryService._();

  static Future<bool> saveMatch(MatchHistoryRecord record) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final records = _decodeRecords(preferences.getString(_storageKey));

      records.removeWhere((item) => item.id == record.id);
      records.add(record);
      records.sort(
        (left, right) => right.finishedAt.compareTo(left.finishedAt),
      );

      final cappedRecords = <MatchHistoryRecord>[];
      final countsBySport = <String, int>{};
      for (final item in records) {
        final currentCount = countsBySport[item.sport] ?? 0;
        if (currentCount >= _maxStoredPerSport) {
          continue;
        }
        cappedRecords.add(item);
        countsBySport[item.sport] = currentCount + 1;
      }

      return await preferences.setString(
        _storageKey,
        jsonEncode(cappedRecords.map((item) => item.toJson()).toList()),
      );
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<List<MatchHistoryRecord>> loadMatches() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final records = _decodeRecords(preferences.getString(_storageKey));
      records.sort(
        (left, right) => right.finishedAt.compareTo(left.finishedAt),
      );
      return records;
    } on PlatformException {
      return [];
    } on MissingPluginException {
      return [];
    }
  }

  static Future<LinkedHashMap<String, List<MatchHistoryRecord>>>
  loadLatestMatchesBySport({int limitPerSport = 5}) async {
    final records = await loadMatches();
    final grouped = <String, List<MatchHistoryRecord>>{};

    for (final record in records) {
      final sportRecords = grouped.putIfAbsent(record.sport, () => []);
      if (sportRecords.length >= limitPerSport) {
        continue;
      }
      sportRecords.add(record);
    }

    final sortedEntries = grouped.entries.toList()
      ..sort(
        (left, right) =>
            right.value.first.finishedAt.compareTo(left.value.first.finishedAt),
      );

    return LinkedHashMap<String, List<MatchHistoryRecord>>.fromEntries(
      sortedEntries,
    );
  }

  static List<MatchHistoryRecord> _decodeRecords(String? rawJson) {
    if (rawJson == null || rawJson.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! List<dynamic>) {
        return [];
      }

      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .map(MatchHistoryRecord.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }
}
