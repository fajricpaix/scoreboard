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
                gradient: LinearGradient(
                  colors: [Colors.orange, Colors.orange.withAlpha(209)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(31),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withAlpha(128),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.add_circle_outline,
                        size: 38 - (12 * progress),
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
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
                              fontSize: 18,
                              letterSpacing: 0.3,
                            ),
                          ),
                          if (descOpacity > 0) ...[
                            const SizedBox(height: 4),
                            Opacity(
                              opacity: descOpacity,
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
