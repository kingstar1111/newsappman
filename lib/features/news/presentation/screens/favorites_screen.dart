import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newsappman/features/news/data/model/article.dart';
import 'package:newsappman/features/news/presentation/providers/favorites_provider.dart';
import 'package:newsappman/features/news/presentation/screens/news_screen.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Article> _filterFavorites(List<Article> favorites) {
    if (_searchQuery.isEmpty) return favorites;

    final query = _searchQuery.toLowerCase();
    return favorites.where((article) {
      final title = article.title?.toLowerCase() ?? '';
      final description = article.description?.toLowerCase() ?? '';
      final source = article.sourceName?.toLowerCase() ?? '';
      return title.contains(query) ||
          description.contains(query) ||
          source.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);
    final filteredFavorites = _filterFavorites(favorites);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('favorites'.tr()),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'search'.tr(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
      ),
      body: favorites.isEmpty
          ? Center(child: Text('no_favorites'.tr()))
          : filteredFavorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'no_results'.tr(),
                        style: TextStyle(color: colorScheme.outline),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: filteredFavorites.length,
                  itemBuilder: (context, index) {
                    return ArticleCard(article: filteredFavorites[index]);
                  },
                ),
    );
  }
}
