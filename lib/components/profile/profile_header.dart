import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scoreboard/theme/index.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      padding: const EdgeInsets.all(20.0),
      child: Stack(
        children: [
          Positioned.fill(
            top: 80,
            left: 32,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 160,
                height: 160,
                child: Opacity(
                  opacity: 0.2,
                  child: SvgPicture.asset(
                    'assets/sports/tennis.svg',
                    fit: BoxFit.contain,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: -16,
            child: IgnorePointer(
              child: Image.asset(
                'assets/icon/tennis.webp',
                width: 280,
                fit: BoxFit.contain,
              ),
            ),
          ),
          FractionallySizedBox(
            widthFactor: 0.6,
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/icon/indonesia.png', height: 38),
                const SizedBox(height: 20),
                const Text(
                  'Muhammad Fajri',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
