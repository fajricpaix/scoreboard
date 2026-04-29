import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();

  static const String _serverClientId =
      '771344322705-ta804621arvfv68gjlvhjiuip92jaeci.apps.googleusercontent.com';

  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool _isInitialized = false;
  static Object? _initializationError;

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      await _googleSignIn.initialize(serverClientId: _serverClientId);
      _isInitialized = true;
      _initializationError = null;
    } catch (error) {
      _isInitialized = false;
      _initializationError = error;
    }
  }

  static bool get isReady => _isInitialized;

  static Object? get initializationError => _initializationError;

  static Stream<User?> authStateChanges() {
    if (!_isInitialized) {
      return const Stream<User?>.empty();
    }

    return _firebaseAuth.authStateChanges();
  }

  static User? get currentUser =>
      _isInitialized ? _firebaseAuth.currentUser : null;

  static Future<void> signInWithGoogle() async {
    if (!_isInitialized) {
      throw StateError('Firebase belum dikonfigurasi.');
    }

    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    if (googleAuth.idToken == null) {
      throw const GoogleSignInException(
        code: GoogleSignInExceptionCode.clientConfigurationError,
        description: 'ID token Google tidak tersedia.',
      );
    }

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    await _firebaseAuth.signInWithCredential(credential);
  }

  static String describeSignInError(Object error) {
    if (error is GoogleSignInException) {
      switch (error.code) {
        case GoogleSignInExceptionCode.canceled:
          return 'Masuk dengan Google dibatalkan.';
        case GoogleSignInExceptionCode.interrupted:
          return 'Proses masuk terputus. Coba lagi.';
        case GoogleSignInExceptionCode.uiUnavailable:
          return 'Google Sign-In tidak tersedia di perangkat ini.';
        case GoogleSignInExceptionCode.clientConfigurationError:
          return 'Konfigurasi Google Sign-In belum valid. Pastikan package name dan SHA-1 Android sudah terdaftar di Firebase.';
        case GoogleSignInExceptionCode.providerConfigurationError:
          return 'Provider Google belum aktif atau konfigurasi OAuth belum lengkap di Firebase.';
        case GoogleSignInExceptionCode.userMismatch:
          return 'Akun Google yang dipilih tidak cocok dengan sesi yang sedang aktif. Coba logout lalu masuk lagi.';
        case GoogleSignInExceptionCode.unknownError:
          return error.description == null || error.description!.isEmpty
              ? 'Terjadi kesalahan Google Sign-In yang belum dikenali.'
              : error.description!;
      }
    }

    if (error is FirebaseAuthException) {
      return error.message ?? 'Firebase Auth gagal memproses login Google.';
    }

    if (error is StateError) {
      return error.message;
    }

    return 'Gagal masuk dengan Google. Coba lagi.';
  }

  static Future<void> signOut() async {
    if (!_isInitialized) {
      return;
    }

    await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
  }
}
