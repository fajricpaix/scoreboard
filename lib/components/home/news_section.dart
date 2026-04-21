import 'package:flutter/material.dart';
import 'package:scoreboard/components/home/news_api_service.dart';
import 'package:scoreboard/components/home/news_card.dart';
import 'package:scoreboard/pages/home/news/read.dart';
import 'package:scoreboard/theme/index.dart';

class NewsSection extends StatefulWidget {
  final int itemCount;

  const NewsSection({super.key, this.itemCount = 5});

  @override
  State<NewsSection> createState() => _NewsSectionState();
}

class _NewsSectionState extends State<NewsSection> {
  late final Future<List<NewsArticle>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = NewsApiService.fetchTopSportsNews(pageSize: widget.itemCount);
  }

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
          FutureBuilder<List<NewsArticle>>(
            future: _newsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  children: List.generate(
                    3,
                    (index) => const _NewsLoadingCard(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return _NewsInfoMessage(
                  icon: Icons.newspaper_outlined,
                  message: snapshot.error.toString(),
                );
              }

              final articles = snapshot.data ?? const <NewsArticle>[];

              if (articles.isEmpty) {
                return const _NewsInfoMessage(
                  icon: Icons.inbox_outlined,
                  message: 'Belum ada berita yang tersedia saat ini.',
                );
              }

              return Column(
                children: articles
                    .map(
                      (article) => NewsCard(
                        article: article,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReadNewsPage(article: article),
                            ),
                          );
                        },
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NewsInfoMessage extends StatelessWidget {
  final IconData icon;
  final String message;

  const _NewsInfoMessage({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _NewsLoadingCard extends StatelessWidget {
  const _NewsLoadingCard();

  @override
  Widget build(BuildContext context) {
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
        child: const Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: ColoredBox(color: Color(0xFFE5E7EB)),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 14,
                      width: double.infinity,
                      child: ColoredBox(color: Color(0xFFE5E7EB)),
                    ),
                    SizedBox(height: 8),
                    SizedBox(
                      height: 12,
                      width: double.infinity,
                      child: ColoredBox(color: Color(0xFFF3F4F6)),
                    ),
                    SizedBox(height: 6),
                    SizedBox(
                      height: 12,
                      width: 96,
                      child: ColoredBox(color: Color(0xFFF3F4F6)),
                    ),
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
