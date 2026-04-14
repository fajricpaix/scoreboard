import 'dart:async';
import 'package:flutter/material.dart';
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
              delegate: _AddMatchHeaderDelegate(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateMatchPage(),
                    ),
                  );
                },
              ),
            ),
            // Carousel Image
            const SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: 16),
                  _AutoCarousel(),
                  SizedBox(height: 24),
                ],
              ),
            ),
            // News & Event Section
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        'News & Event',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    ...List.generate(8, (newsIndex) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                ),
                                child: Image.network(
                                  'https://picsum.photos/seed/news$newsIndex/80/80',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Judul Berita $newsIndex',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Deskripsi singkat berita dan event yang menarik untuk kamu baca lebih lanjut.',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddMatchHeaderDelegate extends SliverPersistentHeaderDelegate {
  final VoidCallback onTap;

  const _AddMatchHeaderDelegate({required this.onTap});

  // Tinggi penuh: container 120 + padding atas 12 + padding bawah 12
  static const double _maxExtent = 144.0;
  // Tinggi compact: hanya ikon + judul (tanpa deskripsi)
  static const double _minExtent = 80.0;

  @override
  double get maxExtent => _maxExtent;

  @override
  double get minExtent => _minExtent;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double progress =
        (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final double descOpacity = 1.0 - progress;

    return Material(
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 56 - (24 * progress),
                    color: textColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pertandingan Baru',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        if (descOpacity > 0) ...[
                          const SizedBox(height: 4),
                          Opacity(
                            opacity: descOpacity,
                            child: const Text(
                              'Buat pertandingan baru dan jangan lupa untuk mengundang temanmu!',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right,
                    size: 32,
                    color: textColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _AddMatchHeaderDelegate oldDelegate) =>
      onTap != oldDelegate.onTap;
}

class _AutoCarousel extends StatefulWidget {
  const _AutoCarousel();

  @override
  State<_AutoCarousel> createState() => _AutoCarouselState();
}

class _AutoCarouselState extends State<_AutoCarousel> {
  static const _images = [
    'https://picsum.photos/400/180?random=1',
    'https://picsum.photos/400/180?random=2',
    'https://picsum.photos/400/180?random=3',
  ];

  // Offset besar agar bisa scroll ke dua arah secara "infinite"
  static const int _multiplier = 1000;

  late final PageController _controller;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    final initialPage = _images.length * _multiplier;
    _currentPage = initialPage;
    _controller = PageController(
      viewportFraction: 0.9,
      initialPage: initialPage,
    );
    _controller.addListener(() {
      final page = _controller.page?.round() ?? _currentPage;
      if (page != _currentPage) {
        setState(() => _currentPage = page);
      }
    });
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _controller,
        itemBuilder: (context, index) {
          final imgIndex = index % _images.length;
          final isActive = index == _currentPage;
          return AnimatedScale(
            scale: isActive ? 1.0 : 0.93,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _images[imgIndex],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
