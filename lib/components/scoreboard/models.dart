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
