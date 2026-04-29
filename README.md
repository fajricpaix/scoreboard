# scoreboard

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase Login Setup

History dan Profile sekarang meminta login Google melalui Firebase Auth.

Sebelum menjalankan aplikasi, lengkapi setup berikut:

1. Buat aplikasi Android dan iOS di Firebase project Anda.
2. Aktifkan provider Google di Firebase Authentication.
3. Unduh `google-services.json` lalu simpan ke `android/app/google-services.json`.
4. Unduh `GoogleService-Info.plist` lalu tambahkan ke target `ios/Runner`.
5. Jalankan `flutter pub get`.
6. Jalankan ulang aplikasi.

Jika Anda memakai FlutterFire CLI, konfigurasi native bisa dibuat dengan `flutterfire configure` lalu sesuaikan project ini dengan file output yang dihasilkan.
