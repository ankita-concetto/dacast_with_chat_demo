import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  @JsonKey(name: "type")
  String? type;

  @JsonKey(name: "data")
  Object? data;

  Message({this.type, this.data});

  /// Converts Json string to Map Object
  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

  /// Converts Object to Json String
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
