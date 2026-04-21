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
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
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
}
