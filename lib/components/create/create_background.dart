import 'dart:ui';

import 'package:flutter/material.dart';

class CreateBackground extends StatelessWidget {
  final Widget child;
  final String imageAsset;
  final double imageOpacity;
  final double blurSigma;

  const CreateBackground({
    super.key,
    required this.child,
    this.imageAsset = 'assets/icon/match_vector.jpg',
    this.imageOpacity = 0.35,
    this.blurSigma = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Opacity(
              opacity: imageOpacity,
              child: Image.asset(imageAsset, fit: BoxFit.cover),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
