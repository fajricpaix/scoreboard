import 'package:flutter/material.dart';
import 'package:scoreboard/theme/index.dart';

class _Sport {
  final String name;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final Color accentColor;

  const _Sport({
    required this.name,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.accentColor,
  });
}

const _sports = [
  _Sport(
    name: 'Tenis',
    description:
        'Permainan raket satu lawan satu di lapangan dengan net, menggunakan bola karet bertennis.',
    icon: Icons.sports_tennis,
    gradientColors: [Color(0xFF0D7377), Color(0xFF14A085)],
    accentColor: Color(0xFF3FFFD1),
  ),
  _Sport(
    name: 'Padel',
    description:
        'Olahraga raket di lapangan tertutup bertembok, perpaduan tenis dan squash yang dinamis.',
    icon: Icons.sports_tennis,
    gradientColors: [Color(0xFF1A237E), Color(0xFF3949AB)],
    accentColor: Color(0xFF82B1FF),
  ),
  _Sport(
    name: 'Badminton',
    description:
        'Permainan bulu tangkis dengan shuttlecock yang membutuhkan kecepatan, kelincahan, dan strategi.',
    icon: Icons.sports_esports_outlined,
    gradientColors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
    accentColor: Color(0xFFEA80FC),
  ),
];

class CreateMatchPage extends StatelessWidget {
  const CreateMatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        titleSpacing: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Buat Pertandingan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        children: [
          const Text(
            'Pilih Olahraga',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          ..._sports.map((sport) => _SportCard(sport: sport)),
        ],
      ),
    );
  }
}

class _SportCard extends StatelessWidget {
  final _Sport sport;

  const _SportCard({required this.sport});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {},
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: sport.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: sport.gradientColors.last.withOpacity(0.45),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Row(
                children: [
                  // Icon bubble
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: sport.accentColor.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      sport.icon,
                      color: sport.accentColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Text section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sport.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sport.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12.5,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Arrow
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: sport.accentColor,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}