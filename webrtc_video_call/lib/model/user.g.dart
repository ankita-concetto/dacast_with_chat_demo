// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      userId: json['userId'] as String?,
      channelName: json['channelName'] as String?,
      firstName: json['firstname'] as String?,
      lastName: json['lastname'] as String?,
      password: json['password'] as String?,
      username: json['username'] as String?,
      pushNotificationToken: json['pushNotificationToken'] as String?,
      deviceId: json['deviceId'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('userId', instance.userId);
  writeNotNull('firstname', instance.firstName);
  writeNotNull('lastname', instance.lastName);
  writeNotNull('password', instance.password);
  writeNotNull('username', instance.username);
  writeNotNull('deviceId', instance.deviceId);
  writeNotNull('pushNotificationToken', instance.pushNotificationToken);
  writeNotNull('channelName', instance.channelName);
  return val;
}
