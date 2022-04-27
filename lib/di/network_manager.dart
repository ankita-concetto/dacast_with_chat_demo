import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';


///
/// This class checks if device has internet connectivity or not
///
class NetworkManager {
  final StreamController<bool?> _onInternetConnected = StreamController.broadcast();

  Stream<bool?> get internetConnectionStream => _onInternetConnected.stream;

  Connectivity connectivity = Connectivity();

  bool? _isInternetConnected;

  initialiseNetworkManager() async {
    ConnectivityResult result = await connectivity.checkConnectivity();
    _checkStatus(result);
    connectivity.onConnectivityChanged.listen((result) {
      _checkStatus(result);
    });
  }

  Future<bool?> isConnected() async {
    ConnectivityResult result = await connectivity.checkConnectivity();
    return await _checkStatus(result);
  }

  Future<bool?> _checkStatus(ConnectivityResult result) async {
    bool? isInternet = false;
    switch (result) {
      case ConnectivityResult.wifi:
        isInternet = true;
        break;
      case ConnectivityResult.mobile:
        isInternet = true;
        break;
      case ConnectivityResult.none:
        isInternet = false;
        break;
      default:
        isInternet = false;
        break;
    }
    if (isInternet) isInternet = await _updateConnectionStatus();
    if (_isInternetConnected == null || _isInternetConnected != isInternet) {
      _isInternetConnected = isInternet;
      _onInternetConnected.sink.add(isInternet);
    }
    return isInternet;
  }

  Future<bool?> _updateConnectionStatus() async {
    bool? isConnected;
    try {
      final List<InternetAddress> result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isConnected = true;
      }
    } on SocketException catch (_) {
      isConnected = false;
      return false;
    }
    return isConnected;
  }

  disposeStream() {
    _onInternetConnected.close();
  }
}
