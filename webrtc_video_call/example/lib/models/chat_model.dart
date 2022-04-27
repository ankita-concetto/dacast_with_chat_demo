import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'chat_model.g.dart';

@HiveType(typeId: 2)
class ChatModel extends HiveObject{
  @HiveField(0)
  String? message;

  @HiveField(1)
  String? userId;

  @HiveField(2)
  String? messageStatus;

  @HiveField(3)
  int? messageId;

  @HiveField(4)
  String? senderId;

  @HiveField(5)
  String? date;

  @HiveField(6)
  String? attachment;

  @HiveField(7)
  bool? isAttchmentUploading;

  ChatModel({
    this.message,
    this.userId,
    this.senderId,
    this.messageStatus,
    this.messageId,
    this.date,
    this.attachment,
    this.isAttchmentUploading,
  });

  Map<String, dynamic> toMap(){
    return <String, dynamic>{
      "message":message,
      "userId" : userId,
      "senderId" : senderId,
      "messageStatus": messageStatus,
      "messageId": messageId,
      "date":date,
      "attachment": attachment,
    };
  }
}


class ChatAdapter extends TypeAdapter<ChatModel>{
  @override
  ChatModel read(BinaryReader reader) {
    debugPrint('read: ${reader.read()}');
    return reader.read();
  }

  @override
  // TODO: implement typeId
  int get typeId => 2;

  @override
  void write(BinaryWriter writer, ChatModel obj) {
    writer.write(obj.messageId);
    writer.write(obj.senderId);
    writer.write(obj.userId);
    writer.write(obj.message);
    writer.write(obj.messageStatus);
    writer.write(obj.date);
    writer.write(obj.attachment);
    writer.write(obj.isAttchmentUploading);
  }

}