import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../models/article.dart';
import '../theme/app_theme.dart';

class ArticleCard extends StatelessWidget {
  final Article article;

  const ArticleCard({super.key, required this.article});

  Future<void> _openArticle() async {
    final uri = Uri.parse(article.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: InkWell(
        onTap: _openArticle,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article.imageUrl != null) ...[
                _ArticleThumbnail(imageUrl: article.imageUrl!),
                const SizedBox(width: 12),
              ],
              Expanded(child: _ArticleInfo(article: article)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArticleThumbnail extends StatelessWidget {
  final String imageUrl;

  const _ArticleThumbnail({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: 88,
        height: 68,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          width: 88,
          height: 68,
          color: AppTheme.surfaceColor,
          child: const Icon(Icons.image_outlined, color: Colors.grey, size: 28),
        ),
        errorWidget: (_, __, ___) => Container(
          width: 88,
          height: 68,
          color: AppTheme.surfaceColor,
          child: const Icon(Icons.broken_image_outlined, color: Colors.grey, size: 28),
        ),
      ),
    );
  }
}

class _ArticleInfo extends StatelessWidget {
  final Article article;

  const _ArticleInfo({required this.article});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SourceBadge(name: article.sourceDisplayName),
        const SizedBox(height: 6),
        Text(
          article.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.4,
            color: Colors.white,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.access_time_rounded, size: 11, color: Colors.grey),
            const SizedBox(width: 3),
            Text(
              DateFormat('M/d HH:mm').format(article.publishedAt.toLocal()),
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
            const Spacer(),
            const Icon(Icons.open_in_new_rounded, size: 13, color: Colors.grey),
          ],
        ),
      ],
    );
  }
}

class _SourceBadge extends StatelessWidget {
  final String name;

  const _SourceBadge({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.f1Red.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppTheme.f1Red.withOpacity(0.3)),
      ),
      child: Text(
        name,
        style: const TextStyle(
          color: AppTheme.f1Red,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
