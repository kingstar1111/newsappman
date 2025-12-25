import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newsappman/features/news/data/model/source_model.dart';
import 'package:newsappman/features/news/presentation/providers/sources_provider.dart';

class AddSourceScreen extends ConsumerStatefulWidget {
  const AddSourceScreen({super.key});

  @override
  ConsumerState<AddSourceScreen> createState() => _AddSourceScreenState();
}

class _AddSourceScreenState extends ConsumerState<AddSourceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  String _selectedCategory = 'general';
  String _selectedLanguage = 'en';

  final List<String> _categories = [
    'general',
    'business',
    'entertainment',
    'health',
    'science',
    'sports',
    'technology',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _saveSource() {
    if (_formKey.currentState!.validate()) {
      final newSource = NewsSource.create(
        name: _nameController.text,
        url: _urlController.text,
        category: _selectedCategory,
        language: _selectedLanguage,
      );

      ref.read(sourcesProvider.notifier).addSource(newSource);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('add_source'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'source_name'.tr(),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please_enter_name'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'rss_url'.tr(),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.link),
                  hintText: 'https://example.com/feed',
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please_enter_url'.tr();
                  }
                  if (!Uri.parse(value).isAbsolute) {
                    return 'invalid_url'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'category'.tr(),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.tr())))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedCategory = value);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: _selectedLanguage,
                decoration: InputDecoration(
                  labelText: 'language'.tr(),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.language),
                ),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ar', child: Text('العربية')),
                  DropdownMenuItem(value: 'tr', child: Text('Türkçe')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _selectedLanguage = value);
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saveSource,
                icon: const Icon(Icons.save),
                label: Text('save_source'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
