import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webrtccommunication/webrtccommunication.dart';

class LiveStreamingListController extends SuperController {
  RxString name = ''.obs;
  @override
  Future<void> onInit() async {
    super.onInit();
    debugPrint('${Get.arguments}');
    name.value = Get.arguments['name'] ?? '';
    print("name = ${name.value}");
  }

  @override
  void onDetached() {
    // TODO: implement onDetached
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
  }

  @override
  void onPaused() {
    // TODO: implement onPaused
  }

  @override
  void onResumed() {
    // TODO: implement onResumed
  }

  @override
  Future<void> onClose() async {
    await WebRtcCommunication.instance.close();
    debugPrint('onDetached');
    super.onClose();
  }

  generateRandomNumber() {
    return Random().nextInt(99999);
  }

}