// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'labels.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LabelAdapter extends TypeAdapter<Label> {
  @override
  final int typeId = 1;

  @override
  Label read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Label(
      fields[0] as String,
      fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Label obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.label)
      ..writeByte(1)
      ..write(obj.color);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
