import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scoreboard/pages/auth/login_prompt_page.dart';
import 'package:scoreboard/services/auth_service.dart';

class AuthRequired extends StatelessWidget {
  const AuthRequired({
    super.key,
    required this.child,
    required this.title,
    required this.message,
  });

  final Widget child;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    if (!AuthService.isReady) {
      return LoginPromptPage(
        title: title,
        message: message,
        actionEnabled: false,
        errorText:
            'Firebase belum siap. Tambahkan file google-services.json dan GoogleService-Info.plist dari proyek Firebase Anda.',
      );
    }

    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          return child;
        }

        return LoginPromptPage(title: title, message: message);
      },
    );
  }
}