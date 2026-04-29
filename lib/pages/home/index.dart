import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scoreboard/components/home/add_match_header.dart';
import 'package:scoreboard/components/home/auto_carousel.dart';
import 'package:scoreboard/components/home/news_section.dart';
import 'package:scoreboard/components/utils/ads.dart';
import 'package:scoreboard/pages/create/index.dart';
import 'package:scoreboard/theme/index.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String greeting = _greeting();
    final String name = user?.displayName ?? 'Pengguna';

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Greeting header (hanya jika sudah login)
            if (user != null)
              SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Tombol pertandingan baru - sticky saat scroll
            SliverPersistentHeader(
              pinned: true,
              delegate: AddMatchHeaderDelegate(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateMatchPage()),
                  );
                },
              ),
            ),
            // Carousel Image
            const SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: 16),
                  AutoCarousel(),
                  SizedBox(height: 24),
                ],
              ),
            ),
            // News & Event Section
            const SliverToBoxAdapter(child: NewsSection()),
            const SliverToBoxAdapter(child: AppBannerAd()),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final int hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi,';
    if (hour < 15) return 'Selamat Siang,';
    if (hour < 18) return 'Selamat Sore,';
    return 'Selamat Malam,';
  }
}
