import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newsappman/features/news/presentation/providers/sources_provider.dart';
import 'package:newsappman/features/news/presentation/screens/add_source_screen.dart';

class ManageSourcesScreen extends ConsumerWidget {
  const ManageSourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sources = ref.watch(sourcesProvider);

    return Scaffold(
      appBar: AppBar(title: Text('manage_sources'.tr())),
      body: sources.isEmpty
          ? Center(child: Text('no_sources'.tr()))
          : ListView.builder(
              itemCount: sources.length,
              itemBuilder: (context, index) {
                final source = sources[index];
                return ListTile(
                  title: Text(source.name),
                  subtitle: Text(
                    '${source.category.tr()} - ${source.language.tr()}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      ref
                          .read(sourcesProvider.notifier)
                          .removeSource(source.id);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddSourceScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
