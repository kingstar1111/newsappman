// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'source_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NewsSourceAdapter extends TypeAdapter<NewsSource> {
  @override
  final int typeId = 2;

  @override
  NewsSource read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NewsSource(
      id: fields[0] as String,
      name: fields[1] as String,
      url: fields[2] as String,
      category: fields[3] as String,
      language: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, NewsSource obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.url)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.language);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewsSourceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
