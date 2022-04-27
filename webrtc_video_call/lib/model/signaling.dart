import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'signaling.g.dart';

@JsonSerializable()
class Signaling {
  @JsonKey(name: "type")
  String? signalingType;

  @JsonKey(name: "message", fromJson: convertToString)
  String? message;

  Signaling({this.signalingType, this.message});

  /// Converts Json string to Map Object
  factory Signaling.fromJson(Map<String, dynamic> json) =>
      _$SignalingFromJson(json);

  /// Converts Object to Json String
  Map<String, dynamic> toJson() => _$SignalingToJson(this);

  static convertToString(value) {
    print('value: $value');
    if (value == null) return "";
    return const JsonEncoder().convert(Map<String, dynamic>.from(value));
  }
}
