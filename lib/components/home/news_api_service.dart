import 'dart:convert';

import 'package:http/http.dart' as http;

class NewsApiException implements Exception {
  final String message;

  const NewsApiException(this.message);

  @override
  String toString() => message;
}

class NewsArticle {
  final String title;
  final String description;
  final String? imageUrl;
  final String sourceName;
  final DateTime? publishedAt;
  final String? url;
  final String content;

  const NewsArticle({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.sourceName,
    required this.publishedAt,
    required this.url,
    required this.content,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    final source = json['source'];
    final sourceName = source is Map<String, dynamic>
        ? (source['name'] as String? ?? 'NewsAPI')
        : 'NewsAPI';

    return NewsArticle(
      title: (json['title'] as String? ?? '').trim(),
      description: (json['description'] as String? ?? '').trim(),
      imageUrl: (json['urlToImage'] as String?)?.trim(),
      sourceName: sourceName,
      publishedAt: DateTime.tryParse(json['publishedAt'] as String? ?? ''),
      url: (json['url'] as String?)?.trim(),
      content: (json['content'] as String? ?? '').trim(),
    );
  }
}

class NewsApiService {
  static const String _apiKey = String.fromEnvironment(
    'NEWS_API_KEY',
    defaultValue: '47bead4849504c8f85b80f4e1d29a1fe',
  );

  static Future<List<NewsArticle>> fetchTopSportsNews({
    int pageSize = 8,
  }) async {
    if (_apiKey.isEmpty) {
      throw const NewsApiException(
        'NEWS_API_KEY belum diisi. Jalankan app dengan --dart-define=NEWS_API_KEY=your_key',
      );
    }

    final uri = Uri.https('newsapi.org', '/v2/top-headlines', {
      'country': 'us',
      'category': 'sports',
      'pageSize': '$pageSize',
      'apiKey': _apiKey,
    });

    final response = await http.get(uri);
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 || body['status'] != 'ok') {
      final message = body['message'] as String? ?? 'Gagal memuat berita';
      throw NewsApiException(message);
    }

    final articles = (body['articles'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(NewsArticle.fromJson)
        .where((article) => article.title.isNotEmpty)
        .toList();

    return articles;
  }
}
