// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signaling.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Signaling _$SignalingFromJson(Map<String, dynamic> json) => Signaling(
      signalingType: json['type'] as String?,
      message: Signaling.convertToString(json['message']),
    );

Map<String, dynamic> _$SignalingToJson(Signaling instance) => <String, dynamic>{
      'type': instance.signalingType,
      'message': instance.message,
    };
