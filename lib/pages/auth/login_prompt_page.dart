import 'package:flutter/material.dart';
import 'package:scoreboard/services/auth_service.dart';
import 'package:scoreboard/theme/index.dart';

class LoginPromptPage extends StatefulWidget {
  const LoginPromptPage({
    super.key,
    required this.title,
    required this.message,
    this.actionEnabled = true,
    this.errorText,
  });

  final String title;
  final String message;
  final bool actionEnabled;
  final String? errorText;

  @override
  State<LoginPromptPage> createState() => _LoginPromptPageState();
}

class _LoginPromptPageState extends State<LoginPromptPage> {
  bool _isLoading = false;
  String? _errorText;

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      await AuthService.signInWithGoogle();
    } catch (error) {
      setState(() {
        _errorText = AuthService.describeSignInError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? visibleErrorText = _errorText ?? widget.errorText;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.lock_outline, size: 60, color: Colors.white),
              const SizedBox(height: 20),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: !_isLoading && widget.actionEnabled
                  ? _handleGoogleSignIn
                  : null,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login),
                label: Text(_isLoading ? 'Memproses...' : 'Masuk dengan Google'),
                style: FilledButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: textColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              if (visibleErrorText != null) ...[
                const SizedBox(height: 16),
                Text(
                  visibleErrorText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: error),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}