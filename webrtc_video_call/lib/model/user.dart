import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(includeIfNull: false)
class User {
  String? userId;

  @JsonKey(name: "firstname")
  String? firstName;

  @JsonKey(name: "lastname")
  String? lastName;

  String? password;

  String? username;

  String? deviceId;

  String? pushNotificationToken;

  String? channelName;

  User(
      {this.userId,
      this.channelName,
      this.firstName,
      this.lastName,
      this.password,
      this.username,
      this.pushNotificationToken,
      this.deviceId});

  /// Converts Json string to Map Object
  static fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Converts Object to Json String
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
