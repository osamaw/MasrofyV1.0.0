// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'installment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InstallmentAdapter extends TypeAdapter<Installment> {
  @override
  final int typeId = 2;

  @override
  Installment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Installment(
      name: fields[0] as String,
      totalPrice: fields[1] as double,
      totalMonths: fields[2] as int,
      startDate: fields[3] as DateTime,
      monthlyAmount: fields[4] as double,
      userEmail: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Installment obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.totalPrice)
      ..writeByte(2)
      ..write(obj.totalMonths)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.monthlyAmount)
      ..writeByte(5)
      ..write(obj.userEmail);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InstallmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
