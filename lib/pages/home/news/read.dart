import 'package:flutter/material.dart';
import 'package:scoreboard/components/home/news_api_service.dart';
import 'package:scoreboard/components/home/news_card.dart';
import 'package:scoreboard/theme/index.dart';
import 'package:share_plus/share_plus.dart';

class ReadNewsPage extends StatefulWidget {
  final NewsArticle article;

  const ReadNewsPage({super.key, required this.article});

  @override
  State<ReadNewsPage> createState() => _ReadNewsPageState();
}

class _ReadNewsPageState extends State<ReadNewsPage> {
  late final Future<List<NewsArticle>> _suggestionFuture;

  @override
  void initState() {
    super.initState();
    _suggestionFuture = NewsApiService.fetchTopSportsNews(pageSize: 6);
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Tanggal tidak tersedia';
    }

    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _shareNews() async {
    final shareText = widget.article.url == null || widget.article.url!.isEmpty
        ? widget.article.title
        : '${widget.article.title}\n${widget.article.url}';

    await SharePlus.instance.share(
      ShareParams(text: shareText, subject: widget.article.title),
    );
  }

  String get _articleDescription {
    if (widget.article.content.isNotEmpty) {
      return widget.article.content;
    }

    if (widget.article.description.isNotEmpty) {
      return widget.article.description;
    }

    return 'Konten lengkap tidak tersedia untuk artikel ini.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: textColor,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ReadNewsImage(imageUrl: widget.article.imageUrl),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: _shareNews,
                          icon: const Icon(Icons.share_outlined, size: 18),
                          label: const Text('Share'),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(widget.article.publishedAt),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.article.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _articleDescription,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.7,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Berita Lainnya',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<List<NewsArticle>>(
                      future: _suggestionFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (snapshot.hasError) {
                          return Text(
                            snapshot.error.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          );
                        }

                        final suggestions =
                            (snapshot.data ?? const <NewsArticle>[])
                                .where(
                                  (item) => item.title != widget.article.title,
                                )
                                .take(3)
                                .toList();

                        if (suggestions.isEmpty) {
                          return const Text(
                            'Belum ada rekomendasi berita lainnya.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          );
                        }

                        return Column(
                          children: suggestions
                              .map(
                                (article) => NewsCard(
                                  article: article,
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ReadNewsPage(article: article),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadNewsImage extends StatelessWidget {
  final String? imageUrl;

  const _ReadNewsImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: double.infinity,
        height: 240,
        color: const Color(0xFFF3F4F6),
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: Theme.of(context).primaryColor,
        ),
      );
    }

    return Image.network(
      imageUrl!,
      width: double.infinity,
      height: 240,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: double.infinity,
          height: 240,
          color: const Color(0xFFF3F4F6),
          child: Icon(
            Icons.broken_image_outlined,
            size: 48,
            color: Theme.of(context).primaryColor,
          ),
        );
      },
    );
  }
}
