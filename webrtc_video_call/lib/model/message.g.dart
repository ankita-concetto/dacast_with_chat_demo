// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      type: json['type'] as String?,
      data: json['data'],
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'type': instance.type,
      'data': instance.data,
    };
