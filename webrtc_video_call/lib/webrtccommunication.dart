import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:webrtccommunication/chat/chat_signaling.dart';
import 'package:webrtccommunication/model/message.dart';
import 'package:webrtccommunication/model/signaling.dart';
import 'package:webrtccommunication/model/user.dart';
import 'package:webrtccommunication/utils/socket_configuration.dart';
import 'package:webrtccommunication/utils/websocket.dart';
import 'package:webrtccommunication/video_call/video_signaling.dart';

import 'utils/signaling_constants.dart';

class WebRtcCommunication {
  final SimpleWebSocket _socket = SimpleWebSocket();
  final JsonEncoder _encoder = const JsonEncoder();
  final JsonDecoder _decoder = const JsonDecoder();
  final VideoSignaling _videoSignaling = VideoSignaling();
  final ChatSignaling _chatSignaling = ChatSignaling();

  WebRtcCommunication._privateConstructor();

  static final WebRtcCommunication _instance =
      WebRtcCommunication._privateConstructor();

  static WebRtcCommunication get instance => _instance;

  OnMessageCallback? onMessageCallback;

  void setOnMessageCallback(OnMessageCallback onMessageCallback){
    this.onMessageCallback = onMessageCallback;
  }

  init(
      {String? host,
      String? port,
      int? userId,
      SocketConnectionStatusCallBack? status}) async {
    assert(host != null && port != null && userId != null);
    _socket.onOpen = () async {
      debugPrint("connection established");
      status!(SocketConnectionStatus.CONNECTION_ESTABLISHED);
      sendData(MessageType.addUser, {SignalingConstants.userId: userId});
    };

    _socket.onClose = (int? code, String? reason) {
      debugPrint('Closed by server [$code => $reason]!');
      status!(SocketConnectionStatus.CONNECTION_DISCONNECTED);
    };

    _socket.onMessage = (messageType, message) {
      debugPrint('response socket [$messageType => $message]!');
      status!(SocketConnectionStatus.ONMESSAGE,data: message);
      debugPrint('afterStatus onMessage');
      switch (messageType) {
        case MessageType.addUser:
          debugPrint("User Added: $message");
          onMessageCallback!(messageType,message);
          break;
        case MessageType.videoCall:
          _videoSignaling.onMessage(_decoder.convert(message));
          break;
        case MessageType.chat:
          _chatSignaling.onMessage(_decoder.convert(message));
          onMessageCallback!(messageType,message);
          break;
        case MessageType.checkUnReadMessages:
          break;
        case MessageType.getAllChats:
          break;
        case MessageType.sendMessage:
          debugPrint('---72---- webRtc messageType sendMessage');
          _chatSignaling.onMessage(_decoder.convert(message));
          onMessageCallback!(messageType,message);
          break;

        case MessageType.userStatus:
          _chatSignaling.onMessage(_decoder.convert(message));
          onMessageCallback!(messageType,message);
          break;

        case MessageType.typing:
          _chatSignaling.onMessage(_decoder.convert(message));
          onMessageCallback!(messageType,message);
          break;

        case MessageType.messageStatus:
          onMessageCallback!(messageType,message);
          break;
      }
    };
    print('socket going for connect');
    await _socket.connect('ws://$host:$port');
  }

  close() async {
    await _socket.close();
  }

  configureVideo() {
    _videoSignaling.configureVideo();
  }

  configureAudio() {
    _videoSignaling.configureAudio();
  }

  endCall() {
    _videoSignaling.bye();
  }

  void sendData(MessageType messageType, Object data) {
    String message = _encoder.convert(data);
    print('sendData message: $message');
    Signaling signaling = Signaling(
        message: message, signalingType: messageTypeValue(messageType));
    _socket.send(_encoder.convert(signaling));
  }

  void sendMessage(MessageType messageType, Object data){
    String message = _encoder.convert(data);
    print('sendMessage message: $message');
    Signaling signaling = Signaling(message: message, signalingType: messageTypeValue(messageType));
    _socket.send(_encoder.convert(signaling));
  }

  VideoSignaling get videoSignaling => _videoSignaling;

  ChatSignaling get chatSignaling => _chatSignaling;
}

enum SocketConnectionStatus {
  CONNECTION_ESTABLISHED,
  CONNECTION_DISCONNECTED,
  ONMESSAGE
}

typedef SocketConnectionStatusCallBack(SocketConnectionStatus status,{String? data});
