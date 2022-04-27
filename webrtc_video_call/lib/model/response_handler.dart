import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'response_handler.g.dart';

@JsonSerializable()
class ResponseHandler<T> {
  @JsonKey(name: "status")
  int? status;

  @JsonKey(name: "error")
  bool? error;

  @JsonKey(name: "message")
  String? message;

  @JsonKey(name: "result", fromJson: _dynamicDataFromJson)
  T? data;

  @JsonKey(ignore: true)
  static Function? convert;

  ResponseHandler({this.status, this.error, this.message, this.data});

  static _dynamicDataFromJson<T>(response) {
    if (response != null && convert != null) {
      return convert!(response);
    } else {
      return null;
    }
  }

  /// Converts Json string to Map Object
  factory ResponseHandler.fromJson({@required Map<String, dynamic>? json, @required Function? convertFunction}) {
    ResponseHandler.convert = convertFunction;
    return _$ResponseHandlerFromJson<T>(json ?? {});
  }

  /// Converts Object to Json String
  Map<String, dynamic> toJson() => _$ResponseHandlerToJson(this);
}
