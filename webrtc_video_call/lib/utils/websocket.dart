import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:webrtccommunication/utils/socket_configuration.dart';

typedef OnMessageCallback = void Function(MessageType messageType, String data);
typedef OnCloseCallback = void Function(int? code, String? reason);
typedef OnOpenCallback = void Function();

class SimpleWebSocket {
  WebSocket? _socket;
  OnOpenCallback? onOpen;
  OnMessageCallback? onMessage;
  OnCloseCallback? onClose;

  connect(String webSocketUrl) async {
    try {
      //_socket = await WebSocket.connect(_url);
      _socket = await WebSocket.connect(webSocketUrl);
      if (onOpen != null) {
        onOpen!();
      }
      _socket?.listen((data) {
        print('listen: $data');
        Map<String, dynamic> signaling = json.decode(data);
        print("containKey = ${signaling.containsKey('message')}");
        if (onMessage != null && signaling.containsKey('type') && signaling['type']!=null) {
          if(signaling.containsKey('message')) {
            onMessage!(
                messageType(signaling['type']!), signaling['message'] ?? "");
          }
          if(signaling.containsKey('data')){
            onMessage!(messageType(signaling['type']!), json.encode(signaling['data']));
          }

        }
      }, onDone: () async {
        if (onClose != null) {
          onClose!(_socket?.closeCode, _socket?.closeReason);
        }
      });
    } catch (e) {
      if (onClose != null) {
        onClose!(500, e.toString());
      }
    }
  }

  send(data) {
    if (_socket != null) {
      _socket?.add(data);
      debugPrint('send: $data');
    }
  }

  close() async {
    await _socket?.close();
  }

  Future<WebSocket> _connectForSelfSignedCert(url) async {
    try {
      Random r = Random();
      String key = base64.encode(List<int>.generate(8, (_) => r.nextInt(255)));
      HttpClient client = HttpClient(context: SecurityContext());
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        debugPrint('SimpleWebSocket: Allow self-signed certificate => $host:$port. ');
        return true;
      };

      HttpClientRequest request = await client.getUrl(Uri.parse(url)); // form the correct url here
      request.headers.add('Connection', 'Upgrade');
      request.headers.add('Upgrade', 'websocket');
      request.headers.add('Sec-WebSocket-Version', '13'); // insert the correct version here
      request.headers.add('Sec-WebSocket-Key', key.toLowerCase());

      HttpClientResponse response = await request.close();
      debugPrint("response: " + response.toString());
      Socket socket = await response.detachSocket();
      var webSocket = WebSocket.fromUpgradedSocket(
        socket,
        protocol: 'signaling',
        serverSide: false,
      );

      return webSocket;
    } catch (e) {
      throw e;
    }
  }
}
