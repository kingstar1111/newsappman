import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:newsappman/core/constants/app_secrets.dart';
import 'package:newsappman/core/network/dio_client.dart';
import 'package:newsappman/features/news/data/model/article.dart';
import 'package:newsappman/features/news/data/model/source_model.dart';
import 'package:newsappman/core/storage/hive_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:xml/xml.dart';

part 'news_repository.g.dart';

@riverpod
NewsRepository newsRepository(NewsRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  final hiveService = ref.watch(hiveServiceProvider);
  return NewsRepository(dio, hiveService);
}

class NewsRepository {
  final Dio _dio;
  final HiveService _hiveService;

  NewsRepository(this._dio, this._hiveService);

  Future<List<Article>> getNews({
    required String category,
    required String language,
    required List<NewsSource> customSources,
  }) async {
    List<Article> allArticles = [];
    final String apiKey = AppSecrets.newsApiKey;

    // Prepare Futures for API and RSS
    List<Future<List<Article>>> fetchTasks = [];

    // 1. API Task
    fetchTasks.add(_fetchFromApi(apiKey, category, language));

    // 2. RSS Tasks
    final relevantSources = customSources.where(
      (s) => s.category == category && s.language == language,
    );
    for (final source in relevantSources) {
      fetchTasks.add(_fetchRssFeed(source));
    }

    // 3. Run all in parallel with error handling for each task
    final results = await Future.wait(
      fetchTasks.map((task) => task.catchError((e) {
            debugPrint('Fetch task error: $e');
            return <Article>[];
          })),
    );

    // 4. Merge results (failed tasks return empty lists)
    for (final list in results) {
      allArticles.addAll(list);
    }

    // Sort by date (newest first)
    allArticles.sort((a, b) {
      return (b.publishedAt ?? '').compareTo(a.publishedAt ?? '');
    });

    if (allArticles.isNotEmpty) {
      await _cacheArticles(allArticles);
    } else {
      final cached = _getCachedArticles();
      if (cached.isNotEmpty) {
        return cached;
      }
    }

    return allArticles;
  }

  Future<void> _cacheArticles(List<Article> articles) async {
    await _hiveService.newsBox.clear();
    await _hiveService.newsBox.addAll(articles);
  }

  List<Article> _getCachedArticles() {
    if (_hiveService.newsBox.isOpen) {
      return _hiveService.newsBox.values.cast<Article>().toList();
    }
    return [];
  }

  Future<List<Article>> _fetchFromApi(
    String apiKey,
    String category,
    String language,
  ) async {
    try {
      final response = await _dio.get(
        'https://newsapi.org/v2/top-headlines',
        queryParameters: {
          'apiKey': apiKey,
          'country': language == 'ar'
              ? 'sa'
              : language == 'tr'
                  ? 'tr'
                  : 'us',
          'category': category,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> articlesJson = response.data['articles'];
        return articlesJson.map((json) => Article.fromJson(json)).where((a) {
          return a.title != null && a.url != null && a.urlToImage != null;
        }).toList();
      }
    } catch (e) {
      debugPrint('NewsAPI Error: $e');
    }
    return [];
  }

  Future<List<Article>> _fetchRssFeed(NewsSource source) async {
    try {
      // Use plain response type to get raw XML string
      final response = await _dio.get(
        source.url,
        options: Options(responseType: ResponseType.plain),
      );

      if (response.statusCode == 200) {
        final String xmlString = response.data.toString();
        final document = XmlDocument.parse(xmlString);
        final items = document.findAllElements('item');

        return items.map((node) {
          final title = node.findElements('title').singleOrNull?.innerText;
          final link = node.findElements('link').singleOrNull?.innerText;
          final description =
              node.findElements('description').singleOrNull?.innerText;

          // Extract content:encoded using namespace-aware search
          String? contentEncoded = _findContentEncoded(node);

          final pubDate = node.findElements('pubDate').singleOrNull?.innerText;

          // --- Improved Image Extraction Strategy ---
          String? imageUrl;

          // 1. Try 'enclosure' (Standard RSS)
          imageUrl =
              node.findElements('enclosure').firstOrNull?.getAttribute('url');

          // 2. Try 'media:content' (Yahoo/Media RSS) - search by local name
          if (imageUrl == null) {
            final mediaContent = node.children.whereType<XmlElement>().where(
                (e) => e.localName == 'content' || e.name.local == 'content');
            if (mediaContent.isNotEmpty) {
              imageUrl = mediaContent.first.getAttribute('url');
            }
          }

          // 3. Try 'media:thumbnail' - search by local name
          if (imageUrl == null) {
            final mediaThumbnail = node.children.whereType<XmlElement>().where(
                (e) =>
                    e.localName == 'thumbnail' || e.name.local == 'thumbnail');
            if (mediaThumbnail.isNotEmpty) {
              imageUrl = mediaThumbnail.first.getAttribute('url');
            }
          }

          // 4. Try parsing <img> tag from 'description' or 'content:encoded'
          if (imageUrl == null) {
            final htmlContent = contentEncoded ?? description;
            if (htmlContent != null && htmlContent.contains('<img')) {
              imageUrl = _extractImageFromHtml(htmlContent);
            }
          }

          // Use content:encoded as full content, fallback to description
          final fullContent = contentEncoded ?? description;

          return Article(
            sourceName: source.name,
            author: null,
            title: title,
            description: description,
            url: link,
            urlToImage: imageUrl,
            publishedAt: pubDate,
            content: fullContent,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('RSS Error for ${source.name}: $e');
      return [];
    }
    return [];
  }

  /// Helper to extract image URL from HTML content
  String? _extractImageFromHtml(String htmlContent) {
    // Try double quotes first
    final doubleQuoteRegex = RegExp(r'src\s*=\s*"([^"]+)"');
    final doubleMatch = doubleQuoteRegex.firstMatch(htmlContent);
    if (doubleMatch != null) {
      return doubleMatch.group(1);
    }

    // Try single quotes
    final singleQuoteRegex = RegExp("src\\s*=\\s*'([^']+)'");
    final singleMatch = singleQuoteRegex.firstMatch(htmlContent);
    if (singleMatch != null) {
      return singleMatch.group(1);
    }

    return null;
  }

  /// Helper to find content:encoded element (handles namespace issues)
  String? _findContentEncoded(XmlElement node) {
    // Try direct findElements first
    final direct = node.findElements('content:encoded').singleOrNull;
    if (direct != null) return direct.innerText;

    // Try searching by local name 'encoded'
    final byLocalName = node.children
        .whereType<XmlElement>()
        .where((e) => e.localName == 'encoded' || e.name.local == 'encoded')
        .firstOrNull;
    if (byLocalName != null) return byLocalName.innerText;

    // Try searching for any element with 'content' namespace prefix
    final byPrefix = node.children
        .whereType<XmlElement>()
        .where((e) => e.name.prefix == 'content')
        .firstOrNull;
    if (byPrefix != null) return byPrefix.innerText;

    return null;
  }
}
