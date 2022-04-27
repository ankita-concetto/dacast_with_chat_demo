// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatModelAdapter extends TypeAdapter<ChatModel> {
  @override
  final int typeId = 2;

  @override
  ChatModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatModel(
      message: fields[0] as String?,
      userId: fields[1] as String?,
      senderId: fields[4] as String?,
      messageStatus: fields[2] as String?,
      messageId: fields[3] as int?,
      date: fields[5] as String?,
      attachment: fields[6] as String?,
      isAttchmentUploading: fields[7] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, ChatModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.message)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.messageStatus)
      ..writeByte(3)
      ..write(obj.messageId)
      ..writeByte(4)
      ..write(obj.senderId)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.attachment)
      ..writeByte(7)
      ..write(obj.isAttchmentUploading);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
