// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response_handler.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResponseHandler<T> _$ResponseHandlerFromJson<T>(Map<String, dynamic> json) =>
    ResponseHandler(
      status: json['status'] as int?,
      error: json['error'] as bool?,
      message: json['message'] as String?,
      data: ResponseHandler._dynamicDataFromJson<T>(json['result']),
    );

Map<String, dynamic> _$ResponseHandlerToJson(ResponseHandler instance) =>
    <String, dynamic>{
      'status': instance.status,
      'error': instance.error,
      'message': instance.message,
      'result': instance.data,
    };
