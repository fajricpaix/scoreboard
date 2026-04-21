import 'dart:async';
import 'package:flutter/material.dart';

class AutoCarousel extends StatefulWidget {
  const AutoCarousel({super.key});

  @override
  State<AutoCarousel> createState() => _AutoCarouselState();
}

class _AutoCarouselState extends State<AutoCarousel> {
  static const _images = [
    'assets/banners/1.webp',
    'assets/banners/2.webp',
    'assets/banners/3.webp',
    'assets/banners/4.webp',
    'assets/banners/5.webp',
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
    return AspectRatio(
      aspectRatio: 11 / 6,
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
                child: Image.asset(_images[imgIndex], fit: BoxFit.cover),
              ),
            ),
          );
        },
      ),
    );
  }
}
