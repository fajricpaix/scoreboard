class MatchResult {
  final List<String> winnerNames;
  final List<String> loserNames;

  const MatchResult({required this.winnerNames, required this.loserNames});
}

class ScoreHistoryItem {
  final int leftScore;
  final int rightScore;
  final String note;
  final int? setNumber;

  const ScoreHistoryItem({
    required this.leftScore,
    required this.rightScore,
    required this.note,
    this.setNumber,
  });
}
