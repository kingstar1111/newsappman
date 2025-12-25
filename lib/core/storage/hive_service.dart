import 'package:hive_flutter/hive_flutter.dart';
import 'package:newsappman/features/news/data/model/article.dart';
import 'package:newsappman/features/news/data/model/source_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hive_service.g.dart';

class HiveService {
  static const String newsBoxName = 'newsBox';
  static const String settingsBoxName = 'settingsBox';
  static const String favoritesBoxName = 'favoritesBox';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ArticleAdapter());
    Hive.registerAdapter(NewsSourceAdapter()); // Register NewsSourceAdapter
    await Hive.openBox(newsBoxName);
    await Hive.openBox(settingsBoxName);
    await Hive.openBox(favoritesBoxName);
    await Hive.openBox<NewsSource>('sourcesBox'); // Open sourcesBox
  }

  Box get newsBox => Hive.box(newsBoxName);
  Box get settingsBox => Hive.box(settingsBoxName);
  Box get favoritesBox => Hive.box(favoritesBoxName);
  Box<NewsSource> get sourcesBox => Hive.box<NewsSource>('sourcesBox');

  Future<void> clearNewsCache() async {
    await newsBox.clear();
  }

  Future<void> clearFavorites() async {
    await favoritesBox.clear();
  }
}

@Riverpod(keepAlive: true)
HiveService hiveService(Ref ref) {
  return HiveService();
}
