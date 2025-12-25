import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newsappman/core/storage/hive_service.dart';
import 'package:newsappman/features/news/data/model/source_model.dart';

final sourcesProvider =
    StateNotifierProvider<SourcesNotifier, List<NewsSource>>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return SourcesNotifier(hiveService);
});

class SourcesNotifier extends StateNotifier<List<NewsSource>> {
  final HiveService _hiveService;

  SourcesNotifier(this._hiveService) : super([]) {
    _loadSources();
  }

  void _loadSources() {
    if (_hiveService.sourcesBox.isOpen) {
      final storedSources = _hiveService.sourcesBox.values.toList();
      if (storedSources.isNotEmpty) {
        state = storedSources;
      } else {
        // Add Default Sources for immediate gratification
        final defaultSources = [
          NewsSource.create(
            name: 'BBC News (World)',
            url: 'https://feeds.bbci.co.uk/news/world/rss.xml',
            category: 'general',
            language: 'en',
          ),
          NewsSource.create(
            name: 'Al Jazeera (Arabic)',
            url:
                'https://www.aljazeera.net/aljazeerarss/a7c18636-1c70-4477-b835-427c3858ebf4',
            category: 'general',
            language: 'ar',
          ),
          NewsSource.create(
            name: 'CNN (Tech)',
            url: 'https://rss.cnn.com/rss/cnn_tech.rss',
            category: 'technology',
            language: 'en',
          ),
          NewsSource.create(
            name: 'NTV Dünya',
            url: 'https://www.ntv.com.tr/dunya.rss',
            category: 'general',
            language: 'tr',
          ),
          NewsSource.create(
            name: 'Habertürk',
            url: 'http://www.haberturk.com/rss',
            category: 'general',
            language: 'tr',
          ),
        ];

        // Save to Hive individually
        for (final s in defaultSources) {
          _hiveService.sourcesBox.put(s.id, s);
        }
        state = defaultSources;
      }
    }
  }

  Future<void> addSource(NewsSource source) async {
    await _hiveService.sourcesBox.put(source.id, source);
    state = [...state, source];
  }

  Future<void> removeSource(String id) async {
    await _hiveService.sourcesBox.delete(id);
    state = state.where((s) => s.id != id).toList();
  }
}
