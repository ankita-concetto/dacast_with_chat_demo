import 'dart:html';

import 'package:flutter/material.dart';

typedef OnMessageCallback = void Function(dynamic msg);
typedef OnCloseCallback = void Function(int? code, String? reason);
typedef OnOpenCallback = void Function();

class SimpleWebSocket {
  WebSocket? _socket;
  OnOpenCallback? onOpen;
  OnMessageCallback? onMessage;
  OnCloseCallback? onClose;

  connect(String webSocketUrl) async {
    try {
      _socket = WebSocket(webSocketUrl);
      _socket?.onOpen.listen((e) {
        if (onOpen != null) {
          onOpen!();
        }
      });

      _socket?.onMessage.listen((e) {
        if (onMessage != null) {
          onMessage!(e.data);
        }
      });

      _socket?.onClose.listen((e) {
        if (onClose != null) {
          onClose!(e.code, e.reason);
        }
      });
    } catch (e) {
      if (onClose != null) {
        onClose!(500, e.toString());
      }
    }
  }

  send(data) {
    if (_socket != null && _socket?.readyState == WebSocket.OPEN) {
      _socket?.send(data);
      debugPrint('send: $data');
    } else {
      debugPrint('WebSocket not connected, message $data not sent');
    }
  }

  close() {
    _socket?.close();
  }
}
