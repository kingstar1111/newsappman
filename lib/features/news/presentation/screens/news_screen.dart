import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newsappman/features/news/data/model/article.dart';
import 'package:newsappman/features/news/presentation/providers/news_provider.dart';
import 'package:newsappman/features/news/presentation/providers/favorites_provider.dart';
import 'package:newsappman/features/news/presentation/screens/article_detail_screen.dart';
import 'package:newsappman/features/news/presentation/screens/favorites_screen.dart';
import 'package:newsappman/features/news/presentation/screens/settings_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:timeago/timeago.dart' as timeago;

class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('news_feed'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: newsAsync.when(
        data: (articles) {
          if (articles.isEmpty) {
            return Center(child: Text('no_articles'.tr()));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(newsProvider);
            },
            child: ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return ArticleCard(article: article);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('error'.tr(args: [error.toString()]))),
      ),
    );
  }
}

class ArticleCard extends ConsumerWidget {
  final Article article;

  const ArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoritesProvider).any(
          (element) =>
              (element.url ?? element.title) == (article.url ?? article.title),
        );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ArticleDetailScreen(article: article),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.urlToImage != null)
              Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: article.urlToImage!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, size: 50),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withValues(alpha: 0.8),
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.black87,
                        ),
                        onPressed: () {
                          ref
                              .read(favoritesProvider.notifier)
                              .toggleFavorite(article);
                        },
                      ),
                    ),
                  ),
                ],
              )
            else
              Container(
                height: 150,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Center(
                  child: Icon(
                    Icons.article,
                    size: 64,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article.sourceName != null)
                    Text(
                      article.sourceName!.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    article.title ?? 'No Title',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (article.publishedAt != null)
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatRelativeTime(article.publishedAt!,
                              context.locale.languageCode),
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Parse date string and format as relative time
  String _formatRelativeTime(String dateString, String locale) {
    try {
      // Try parsing ISO 8601 format (from NewsAPI)
      DateTime? dateTime = DateTime.tryParse(dateString);

      // Try parsing RFC 2822 format (from RSS feeds like "Mon, 23 Dec 2024 10:30:00 GMT")
      dateTime ??= _parseRfc2822(dateString);

      if (dateTime != null) {
        // Set locale for timeago
        final localeCode = locale == 'ar'
            ? 'ar'
            : locale == 'tr'
                ? 'tr'
                : 'en';
        return timeago.format(dateTime, locale: localeCode);
      }
    } catch (e) {
      // Fallback to original string on error
    }
    // Fallback: show first 10 chars (date only)
    return dateString.length >= 10 ? dateString.substring(0, 10) : dateString;
  }

  /// Parse RFC 2822 date format (common in RSS feeds)
  DateTime? _parseRfc2822(String dateString) {
    try {
      // Remove timezone name if present and parse
      final cleaned = dateString.replaceAll(RegExp(r'\s+\([^)]+\)'), '');
      return DateTime.tryParse(cleaned);
    } catch (e) {
      return null;
    }
  }
}
