import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'source_model.g.dart';

@HiveType(typeId: 2)
class NewsSource extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String url;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final String language;

  NewsSource({
    required this.id,
    required this.name,
    required this.url,
    required this.category,
    required this.language,
  });

  factory NewsSource.create({
    required String name,
    required String url,
    required String category,
    required String language,
  }) {
    return NewsSource(
      id: const Uuid().v4(),
      name: name,
      url: url,
      category: category,
      language: language,
    );
  }
}
