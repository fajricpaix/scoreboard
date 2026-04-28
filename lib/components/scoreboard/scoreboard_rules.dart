class ScoreboardRules {
  const ScoreboardRules._();

  static bool usesTennisSequence(String sportNameLower) {
    return (sportNameLower.contains('tenis') &&
            !sportNameLower.contains('tenis meja')) ||
        sportNameLower.contains('padel');
  }

  static bool isBadminton(String sportNameLower) {
    return sportNameLower.contains('badminton');
  }

  static bool isTableTennis(String sportNameLower) {
    return sportNameLower.contains('tenis meja');
  }

  static bool isDomino(String sportNameLower) {
    return sportNameLower.contains('domino');
  }

  static bool isBadmintonSetWinner(int score, int opponentScore) {
    if (score >= 30) {
      return true;
    }

    if (score < 21) {
      return false;
    }

    return score - opponentScore >= 2;
  }

  static bool isTableTennisSetWinner(int score, int opponentScore) {
    if (score < 11) {
      return false;
    }

    return score - opponentScore >= 2;
  }

  static bool canSetPoint({
    required int leftScore,
    required int rightScore,
    required bool setAlreadyWon,
    required bool isBadminton,
    required bool isTableTennis,
    required bool usesTennisSequence,
  }) {
    if (setAlreadyWon) {
      return false;
    }

    if (isBadminton) {
      return isBadmintonSetWinner(leftScore, rightScore) ||
          isBadmintonSetWinner(rightScore, leftScore);
    }

    if (isTableTennis) {
      return isTableTennisSetWinner(leftScore, rightScore) ||
          isTableTennisSetWinner(rightScore, leftScore);
    }

    if (!usesTennisSequence) {
      return false;
    }

    final hasAdvantage = leftScore >= 4 || rightScore >= 4;
    if (hasAdvantage) {
      return true;
    }

    final isDeuce = leftScore == 3 && rightScore == 3;
    if (isDeuce) {
      return false;
    }

    final hasForty = leftScore == 3 || rightScore == 3;
    return hasForty;
  }

  static String scoreText({
    required int score,
    required bool isDomino,
    required bool usesTennisSequence,
  }) {
    if (isDomino || !usesTennisSequence) {
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

  static String formatDuration(Duration duration) {
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

  static String? dominoHelperText({
    required bool isDomino,
    required bool setAlreadyWon,
    required bool isDominoResetMode,
  }) {
    if (!isDomino) {
      return null;
    }

    if (setAlreadyWon) {
      return 'Set ini sudah selesai. Pindah ke set lain atau tambah set baru jika diperlukan.';
    }

    if (isDominoResetMode) {
      return 'Mode Reset Angka aktif. Saat Anda input skor untuk satu tim, skor tim lawan otomatis kembali ke 0, lalu skor baru ditambahkan. Tim yang mencapai 101 dinyatakan kalah.';
    }

    return 'Skor dimulai dari 0 - 0. Isi angka tim yang kalah pada ronde ini, lalu skor akan otomatis ditambahkan ke total sebelumnya. Tim yang mencapai 101 dinyatakan kalah.';
  }
}
