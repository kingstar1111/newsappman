import 'package:flutter/material.dart';
import 'package:newsappman/core/storage/hive_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_provider.g.dart';

@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeMode build() {
    return _loadTheme();
  }

  ThemeMode _loadTheme() {
    final hiveService = ref.read(hiveServiceProvider);
    final isDark = hiveService.settingsBox.get('isDark', defaultValue: false);
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final hiveService = ref.read(hiveServiceProvider);
    final isDark = state == ThemeMode.dark;
    await hiveService.settingsBox.put('isDark', !isDark);
    state = !isDark ? ThemeMode.dark : ThemeMode.light;
  }
}
