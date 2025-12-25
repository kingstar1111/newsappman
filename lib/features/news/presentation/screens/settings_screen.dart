import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newsappman/core/storage/hive_service.dart';
import 'package:newsappman/features/news/presentation/providers/settings_provider.dart';
import 'package:newsappman/features/news/presentation/providers/theme_provider.dart';
import 'package:newsappman/features/news/presentation/providers/language_provider.dart';
import 'package:newsappman/features/news/presentation/screens/manage_sources_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const List<String> categories = [
    'general',
    'business',
    'entertainment',
    'health',
    'science',
    'sports',
    'technology',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCategory = ref.watch(settingsProvider);
    final themeMode = ref.watch(themeNotifierProvider);
    final language = ref.watch(languageNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr()),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ═══════════════════════════════════════════════════════════════
          // SECTION: General Settings
          // ═══════════════════════════════════════════════════════════════
          _SettingsSection(
            title: 'general'.tr(),
            children: [
              // Dark Mode Toggle
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'dark_mode'.tr(),
                trailing: Switch.adaptive(
                  value: themeMode == ThemeMode.dark,
                  onChanged: (_) {
                    ref.read(themeNotifierProvider.notifier).toggleTheme();
                  },
                ),
              ),
              const Divider(height: 1, indent: 56),
              // Language Selection
              _SettingsTile(
                icon: Icons.language_outlined,
                title: 'news_language'.tr(),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: language,
                    underline: const SizedBox(),
                    isDense: true,
                    borderRadius: BorderRadius.circular(8),
                    onChanged: (value) async {
                      if (value != null) {
                        ref
                            .read(languageNotifierProvider.notifier)
                            .setLanguage(value);
                        await context.setLocale(Locale(value));
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'ar', child: Text('العربية')),
                      DropdownMenuItem(value: 'tr', child: Text('Türkçe')),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, indent: 56),
              // Category Selection
              _SettingsTile(
                icon: Icons.category_outlined,
                title: 'categories'.tr(),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: currentCategory,
                    underline: const SizedBox(),
                    isDense: true,
                    borderRadius: BorderRadius.circular(8),
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(settingsProvider.notifier).setCategory(value);
                      }
                    },
                    items: categories
                        .map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat.tr()),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ═══════════════════════════════════════════════════════════════
          // SECTION: Sources
          // ═══════════════════════════════════════════════════════════════
          _SettingsSection(
            title: 'sources'.tr(),
            children: [
              _SettingsTile(
                icon: Icons.rss_feed_outlined,
                title: 'manage_sources'.tr(),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ManageSourcesScreen()),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ═══════════════════════════════════════════════════════════════
          // SECTION: Advanced
          // ═══════════════════════════════════════════════════════════════
          _SettingsSection(
            title: 'advanced'.tr(),
            children: [
              _SettingsTile(
                icon: Icons.cleaning_services_outlined,
                title: 'clear_cache'.tr(),
                subtitle: 'clear_cache_desc'.tr(),
                onTap: () => _showClearDialog(
                  context: context,
                  ref: ref,
                  title: 'clear_cache'.tr(),
                  content: 'clear_cache_confirm'.tr(),
                  onConfirm: () async {
                    await ref.read(hiveServiceProvider).clearNewsCache();
                  },
                  successMessage: 'cache_cleared'.tr(),
                ),
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.delete_outline,
                title: 'clear_favorites'.tr(),
                subtitle: 'clear_favorites_desc'.tr(),
                onTap: () => _showClearDialog(
                  context: context,
                  ref: ref,
                  title: 'clear_favorites'.tr(),
                  content: 'clear_favorites_confirm'.tr(),
                  onConfirm: () async {
                    await ref.read(hiveServiceProvider).clearFavorites();
                    ref.invalidate(hiveServiceProvider);
                  },
                  successMessage: 'favorites_cleared'.tr(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _showClearDialog({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String content,
    required Future<void> Function() onConfirm,
    required String successMessage,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'delete'.tr(),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await onConfirm();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
      }
    }
  }
}

/// A section container with a header title
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

/// A single settings tile with consistent styling
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 24),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
