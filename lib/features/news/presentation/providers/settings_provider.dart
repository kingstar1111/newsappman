import 'package:newsappman/core/storage/hive_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_provider.g.dart';

@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  @override
  String build() {
    return _loadCategory();
  }

  String _loadCategory() {
    final hiveService = ref.read(hiveServiceProvider);
    // Ensure the box is open before accessing. In a real app, we might want to ensure initialization in main
    // but HiveService.init() is called in main, so it should be fine if we await correctly.
    // However, build() is synchronous. We might need to ensure Hive is ready.
    // For simplicity passing default value if box not ready or key missing.
    try {
      return hiveService.settingsBox.get('category', defaultValue: 'general');
    } catch (e) {
      return 'general';
    }
  }

  Future<void> setCategory(String category) async {
    final hiveService = ref.read(hiveServiceProvider);
    await hiveService.settingsBox.put('category', category);
    state = category;
  }
}
