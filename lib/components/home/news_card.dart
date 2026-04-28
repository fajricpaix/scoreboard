import 'package:flutter/material.dart';
import 'package:scoreboard/components/home/news_api_service.dart';
import 'package:scoreboard/theme/index.dart';

class NewsCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback? onTap;

  const NewsCard({super.key, required this.article, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.grey[900],
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
                  child:
                      article.imageUrl != null && article.imageUrl!.isNotEmpty
                      ? Image.network(
                          article.imageUrl!,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const _NewsImagePlaceholder(
                              width: 90,
                              height: 90,
                            );
                          },
                        )
                      : const _NewsImagePlaceholder(width: 90, height: 90),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
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
                          article.description.isEmpty
                              ? 'Buka artikel ini untuk membaca detail lengkapnya.'
                              : article.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          article.sourceName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NewsImagePlaceholder extends StatelessWidget {
  final double width;
  final double height;

  const _NewsImagePlaceholder({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        border: Border.all(color: Colors.white10),
      ),
      child: const Center(
        child: Icon(Icons.image_outlined, color: Colors.white70),
      ),
    );
  }
}
