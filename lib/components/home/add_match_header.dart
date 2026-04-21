import 'package:flutter/material.dart';
import 'package:scoreboard/theme/index.dart';

class AddMatchHeaderDelegate extends SliverPersistentHeaderDelegate {
  final VoidCallback onTap;

  const AddMatchHeaderDelegate({required this.onTap});

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
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double progress = (shrinkOffset / (maxExtent - minExtent)).clamp(
      0.0,
      1.0,
    );
    final double descOpacity = 1.0 - progress;
    final double iconBoxSize = 60 - (20 * progress);
    final double iconBoxRadius = 14 - (4 * progress);
    final double iconSize = 38 - (14 * progress);
    final double iconTextGap = 14 - (6 * progress);
    final double contentVerticalPadding = 14 - (8 * progress);

    return Material(
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Ink(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0B1E3A), Color(0xFF102A52)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                image: const DecorationImage(
                  image: AssetImage('assets/icon/match.webp'),
                  fit: BoxFit.cover,
                  opacity: 0.3
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withAlpha(115),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: contentVerticalPadding,
                ),
                child: Row(
                  children: [
                    Container(
                      width: iconBoxSize,
                      height: iconBoxSize,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(31),
                        borderRadius: BorderRadius.circular(iconBoxRadius),
                        border: Border.all(
                          color: Colors.white.withAlpha(128),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.add_circle_outline,
                        size: iconSize,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: iconTextGap),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pertandingan Baru',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              letterSpacing: 0.3,
                            ),
                          ),
                          if (descOpacity > 0.35) ...[
                            const SizedBox(height: 4),
                            Opacity(
                              opacity: (descOpacity - 0.35) / 0.65,
                              child: Text(
                                'Buat pertandingan baru dan jangan lupa untuk mengundang temanmu!',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(179),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant AddMatchHeaderDelegate oldDelegate) =>
      onTap != oldDelegate.onTap;
}
