import 'package:newsappman/features/news/data/model/article.dart';
import 'package:newsappman/features/news/data/repository/news_repository.dart';
import 'package:newsappman/features/news/presentation/providers/settings_provider.dart';
import 'package:newsappman/features/news/presentation/providers/sources_provider.dart'; // Import sources_provider
import 'package:newsappman/features/news/presentation/providers/language_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'news_provider.g.dart';

@riverpod
Future<List<Article>> news(NewsRef ref) async {
  final newsRepository = ref.watch(newsRepositoryProvider);
  final category = ref.watch(settingsProvider);
  final language = ref.watch(languageNotifierProvider);
  final customSources = ref.watch(sourcesProvider);

  return newsRepository.getNews(
    category: category,
    language: language,
    customSources: customSources,
  );
}
