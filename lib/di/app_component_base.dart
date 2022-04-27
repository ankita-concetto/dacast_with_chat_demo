import 'dart:async';
import 'package:dacast_with_chat_demo/di/shared_preference.dart';
import 'package:flutter/material.dart';
import 'network_manager.dart';

class AppComponentBase extends AppComponentBaseRepository {
  static AppComponentBase? _instance;
  final NetworkManager _networkManager = NetworkManager();
  final SharedPreference _sharedPreference = SharedPreference();

  static AppComponentBase? getInstance() {
    _instance ??= AppComponentBase();
    return _instance;
  }

  init() async {
    await _networkManager.initialiseNetworkManager();
    await _sharedPreference.initPreference();
  }

  hideKeyBoard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  String formatSizeUnits(bytes) {
    double tempByte=0.0;
    if (bytes >= 1073741824) {
      tempByte=(bytes / 1073741824);
      bytes = tempByte.toStringAsFixed(2) + " GB";
    } else if (bytes >= 1048576) {
      tempByte=(bytes / 1048576);
      bytes = tempByte.toStringAsFixed(2)  + " MB";
    } else if (bytes >= 1024) {
      tempByte=(bytes / 1024);
      bytes = tempByte.toStringAsFixed(2) + " KB";
    } else if (bytes > 1) {
      bytes = bytes + " bytes";
    } else if (bytes == 1) {
      bytes = bytes + " byte";
    } else {
      bytes = "0 bytes";
    }
    return bytes;
  }

  Future<bool> inInternetAvailable() async{
    bool? isConnected=await _networkManager.isConnected();
    print("isConnected = $isConnected");
    return isConnected??false;
  }

  dispose() {
    _networkManager.disposeStream();
  }

  @override
  SharedPreference getSharedPreference() {
    return _sharedPreference;
  }

  @override
  NetworkManager getNetworkManager() {
    return _networkManager;
  }
}

abstract class AppComponentBaseRepository {
  SharedPreference getSharedPreference();

  NetworkManager getNetworkManager();
}
