import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:newsappman/features/news/data/model/article.dart';
import 'package:newsappman/features/news/presentation/providers/favorites_provider.dart';
import 'package:newsappman/features/news/presentation/screens/webview_screen.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                article.sourceName ?? 'article_source'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: article.urlToImage != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: article.urlToImage!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black54],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      color: Theme.of(context).primaryColor,
                      child: const Center(
                        child: Icon(
                          Icons.article,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
            actions: [
              // Share button
              if (article.url != null)
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {
                    Share.share(
                      '${article.title ?? ''}\n\n${article.url}',
                      subject: article.title,
                    );
                  },
                ),
              // Favorite button
              Consumer(
                builder: (context, ref, child) {
                  final isFavorites = ref.watch(favoritesProvider);
                  final isFavorite = isFavorites.any(
                    (element) =>
                        (element.url ?? element.title) ==
                        (article.url ?? article.title),
                  );
                  return IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: () {
                      ref
                          .read(favoritesProvider.notifier)
                          .toggleFavorite(article);
                    },
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title ?? 'No Title',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 16),
                  if (article.author != null)
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          article.author!,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  if (article.publishedAt != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          article.publishedAt!.substring(0, 10),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  if (article.description != null)
                    Text(
                      article.description!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  const SizedBox(height: 24),
                  if (article.content != null)
                    HtmlWidget(
                      article.content!,
                      textStyle:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                height: 1.6,
                              ),
                      onTapUrl: (url) async {
                        // Handle links if needed, or let system handle
                        return true;
                      },
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: article.url != null
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => WebViewScreen(
                      url: article.url!,
                      title: article.title,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.web),
              label: Text('read_full_article'.tr()),
            )
          : null,
    );
  }
}
