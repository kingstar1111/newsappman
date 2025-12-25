import 'package:newsappman/core/storage/hive_service.dart';
import 'package:newsappman/features/news/data/model/article.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorites_provider.g.dart';

@Riverpod(keepAlive: true)
class Favorites extends _$Favorites {
  @override
  List<Article> build() {
    return _loadFavorites();
  }

  List<Article> _loadFavorites() {
    final hiveService = ref.read(hiveServiceProvider);
    return hiveService.favoritesBox.values.cast<Article>().toList();
  }

  Future<void> toggleFavorite(Article article) async {
    final hiveService = ref.read(hiveServiceProvider);
    final box = hiveService.favoritesBox;

    // We use article.url as the unique key preferably, or composite key
    // Assuming article.url is unique. If null, fallback to title.
    final key = article.url ?? article.title ?? article.hashCode.toString();

    if (box.containsKey(key)) {
      await box.delete(key);
    } else {
      await box.put(key, article);
    }

    state = _loadFavorites();
  }

  bool isFavorite(Article article) {
    return state.any(
      (element) =>
          (element.url ?? element.title) == (article.url ?? article.title),
    );
  }
}
