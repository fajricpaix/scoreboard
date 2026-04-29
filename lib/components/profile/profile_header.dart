import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scoreboard/services/auth_service.dart';
import 'package:scoreboard/theme/index.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  String _resolveUserDisplayName() {
    final user = AuthService.currentUser;
    final String? displayName = user?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final String? email = user?.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }

    return 'Pengguna';
  }

  String _resolveEmailAddress() {
    final String? email = AuthService.currentUser?.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email;
    }

    return _resolveUserDisplayName();
  }

  @override
  Widget build(BuildContext context) {
    final String userDisplayName = _resolveUserDisplayName();
    final String emailAddress = _resolveEmailAddress();
    final String? userPhotoUrl = AuthService.currentUser?.photoURL?.trim();
    final bool hasUserPhoto = userPhotoUrl != null && userPhotoUrl.isNotEmpty;

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
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white24,
                  backgroundImage: hasUserPhoto
                      ? NetworkImage(userPhotoUrl)
                      : null,
                  child: !hasUserPhoto
                      ? const Icon(Icons.person, color: Colors.white, size: 18)
                      : null,
                ),
                const SizedBox(height: 20),
                Text(
                  userDisplayName,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 100),
                Text(
                  emailAddress,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w500,
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
