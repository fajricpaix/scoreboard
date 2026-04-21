import 'package:flutter/material.dart';

class Sport {
  final String name;
  final String description;
  final String iconAsset;
  final List<Color> gradientColors;
  final Color accentColor;

  const Sport({
    required this.name,
    required this.description,
    required this.iconAsset,
    required this.gradientColors,
    required this.accentColor,
  });
}

const sports = [
  Sport(
    name: 'Tenis',
    description:
        'Permainan raket satu lawan satu di lapangan dengan net, menggunakan bola karet bertennis.',
    iconAsset: 'assets/sports/tennis.svg',
    gradientColors: [Color(0xFF0D7377), Color(0xFF14A085)],
    accentColor: Color(0xFF3FFFD1),
  ),
  Sport(
    name: 'Padel',
    description:
        'Olahraga raket di lapangan tertutup bertembok, perpaduan tenis dan squash yang dinamis.',
    iconAsset: 'assets/sports/padel.svg',
    gradientColors: [Color(0xFFC2185B), Color(0xFFE91E63)],
    accentColor: Color(0xFFF48FB1),
  ),
  Sport(
    name: 'Badminton',
    description:
        'Permainan bulu tangkis dengan shuttlecock yang membutuhkan kecepatan, kelincahan, dan strategi.',
    iconAsset: 'assets/sports/badminton.svg',
    gradientColors: [Color(0xFF01579B), Color(0xFF0277BD)],
    accentColor: Color(0xFF80DEEA),
  ),
  Sport(
    name: 'Domino',
    description:
        'Permainan strategi balok bernomor, mencocokkan angka untuk meraih kemenangan.',
    iconAsset: 'assets/sports/domino.svg',
    gradientColors: [Color(0xFFFF0000), Color(0xFFFF6B6B)],
    accentColor: Color(0xFFFFCDD2),
  ),
  Sport(
    name: 'Tenis Meja',
    description:
        'Permainan raket kecil di meja dengan net dan memerlukan refleks cepat dan teknik presisi.',
    iconAsset: 'assets/sports/tenismeja.svg',
    gradientColors: [Color(0xFFF57F00), Color(0xFFFBC02D)],
    accentColor: Color(0xFFFFEE58),
  ),
];

const List<String> gameTypes = ['Single', 'Ganda'];

const List<String> scoringSystems = ['Points', 'Set'];

const List<int> setOptions = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

const List<String> leaderboardRankOptions = ['Point', 'Kemenangan'];
const List<String> dominoScoreModeOptions = ['Biasa', 'Reset Angka'];

class MatchSetup {
  final Sport sport;
  final String matchName;
  final String gameType;
  final String dominoScoreMode;
  final String scoringSystem;
  final int? targetPoints;
  final int? targetSets;
  final String leaderboardRankBy;

  const MatchSetup({
    required this.sport,
    required this.matchName,
    required this.gameType,
    required this.dominoScoreMode,
    required this.scoringSystem,
    required this.targetPoints,
    required this.targetSets,
    required this.leaderboardRankBy,
  });
}
