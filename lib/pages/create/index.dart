import 'package:flutter/material.dart';
import 'package:scoreboard/components/create/models.dart';
import 'package:scoreboard/components/create/sport_card.dart';
import 'package:scoreboard/theme/index.dart';

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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/icon/match_vendor.webp',
              fit: BoxFit.cover,
            ),
          ),
          ListView(
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
          ...sports.map((sport) => SportCard(sport: sport)),
        ],
      ),
        ],
      ),
    );
  }
}

