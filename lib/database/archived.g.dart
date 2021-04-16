// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'archived.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArchivedAdapter extends TypeAdapter<Archived> {
  @override
  final int typeId = 2;

  @override
  Archived read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Archived(
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Archived obj) {
    writer
      ..writeByte(3)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.label);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArchivedAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
