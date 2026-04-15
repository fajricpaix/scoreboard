import 'package:flutter/material.dart';

class Sport {
  final String name;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final Color accentColor;

  const Sport({
    required this.name,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.accentColor,
  });
}

const sports = [
  Sport(
    name: 'Tenis',
    description:
        'Permainan raket satu lawan satu di lapangan dengan net, menggunakan bola karet bertennis.',
    icon: Icons.sports_tennis,
    gradientColors: [Color(0xFF0D7377), Color(0xFF14A085)],
    accentColor: Color(0xFF3FFFD1),
  ),
  Sport(
    name: 'Padel',
    description:
        'Olahraga raket di lapangan tertutup bertembok, perpaduan tenis dan squash yang dinamis.',
    icon: Icons.sports_tennis,
    gradientColors: [Color(0xFF1A237E), Color(0xFF3949AB)],
    accentColor: Color(0xFF82B1FF),
  ),
  Sport(
    name: 'Badminton',
    description:
        'Permainan bulu tangkis dengan shuttlecock yang membutuhkan kecepatan, kelincahan, dan strategi.',
    icon: Icons.sports_esports_outlined,
    gradientColors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
    accentColor: Color(0xFFEA80FC),
  ),
];

const List<String> gameTypes = ['Single', 'Ganda'];

const List<String> scoringSystems = ['Points', 'Set'];

const List<int> setOptions = [3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

const List<String> leaderboardRankOptions = ['Point', 'Kemenangan'];

class MatchSetup {
  final Sport sport;
  final String matchName;
  final String gameType;
  final String scoringSystem;
  final int? targetPoints;
  final int? targetSets;
  final String leaderboardRankBy;

  const MatchSetup({
    required this.sport,
    required this.matchName,
    required this.gameType,
    required this.scoringSystem,
    required this.targetPoints,
    required this.targetSets,
    required this.leaderboardRankBy,
  });
}
