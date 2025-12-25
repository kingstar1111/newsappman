import 'package:newsappman/core/storage/hive_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'language_provider.g.dart';

@Riverpod(keepAlive: true)
class LanguageNotifier extends _$LanguageNotifier {
  @override
  String build() {
    return _loadLanguage();
  }

  String _loadLanguage() {
    final hiveService = ref.read(hiveServiceProvider);
    return hiveService.settingsBox.get('language', defaultValue: 'en');
  }

  Future<void> setLanguage(String language) async {
    final hiveService = ref.read(hiveServiceProvider);
    await hiveService.settingsBox.put('language', language);
    state = language;
  }
}
