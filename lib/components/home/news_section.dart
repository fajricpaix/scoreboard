import 'package:flutter/material.dart';
import 'package:scoreboard/components/home/news_card.dart';
import 'package:scoreboard/theme/index.dart';

class NewsSection extends StatelessWidget {
  final int itemCount;

  const NewsSection({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          ...List.generate(itemCount, (index) => NewsCard(index: index)),
        ],
      ),
    );
  }
}
