// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'testimonial_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TestimonialModelAdapter extends TypeAdapter<TestimonialModel> {
  @override
  final int typeId = 2;

  @override
  TestimonialModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TestimonialModel(
      type: fields[0] as String,
      content: fields[1] as String,
      username: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TestimonialModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.username);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestimonialModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
