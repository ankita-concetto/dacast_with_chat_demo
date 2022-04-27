import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/connect.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:webrtccommunication_example/common/routes.dart';

class FirebaseNotification {
  String? fcmToken;

  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Future<void> init() async {
    fcmToken = await FirebaseMessaging.instance
        .getToken(vapidKey: "AIzaSyDCYXzaOmXxIyOzEGU6YU-ZcLhZW8R_LCk");
    debugPrint('FCM Token: $fcmToken');

    if (!kIsWeb) {
      if (Platform.isAndroid) {
        channel = const AndroidNotificationChannel(
            'high_importance_channel', 'High Importance Notifications',
            description: 'This channel is used for important notifications',
            importance: Importance.high);

        flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);

        await FirebaseMessaging.instance
            .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    }

    FirebaseMessaging.onMessage.listen(backgroundHandler);
    // FirebaseMessaging.onBackgroundMessage(backgroundHandler);
    sendPushMessage();
  }

  Future<void> sendPushMessage() async {
    if (fcmToken == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }

    try {
      Response response = await GetConnect().post(
          "https://fcm.googleapis.com/fcm/send", constructFCMPayload(),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization':
                'Bearer AAAAAUdeRlI:APA91bGdn6_w_RgasuVnrvApmGWrK8SiQTIJgc4ss-mnfsgcy4Vc1UuDVs6tvN8dj3fGzzygi39iqxvdeus3Tj68svJBobAADzag40ESrnGt4tkD_SEj47sOhSXvqYmOJI61IxiIg_fc'
          });
      print('FCM request for device sent! :${response.body}');
    } catch (e) {
      print(e);
    }
  }

// Crude counter to make messages unique
  int _messageCount = 0;

  /// The API endpoint here accepts a raw FCM payload for demonstration purposes.
  String constructFCMPayload() {
    _messageCount++;
    return jsonEncode({
      'to': fcmToken,
      'data': {
        'via': 'FlutterFire Cloud Messaging!!!',
        'count': _messageCount.toString(),
      },
      'notification': {
        'title': 'Hello FlutterFire!',
        'body': 'This notification (#$_messageCount) was created via FCM!',
      },
    });
  }

  Future<void> backgroundHandler(RemoteMessage message) async {
    debugPrint('--> Remote Message Data: ${message.data.toString()}');
    debugPrint('--> Title: ${message.notification!.title}');
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification!.android;
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
              android: AndroidNotificationDetails(channel.id, channel.name,
                  channelDescription: channel.description,
                  icon: 'chat_icon')));
    }

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('onMessageOpenedApp: ${message.data}');
      Get.toNamed(RouteName.root);
    });
  }
}
