import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:webrtccommunication/model/chat.dart';
import 'package:webrtccommunication/model/get_all_chats.dart';
import 'package:webrtccommunication/model/message.dart';
import 'package:webrtccommunication/utils/signaling_constants.dart';
import 'package:webrtccommunication/utils/socket_configuration.dart' as socket_config;
import 'package:webrtccommunication/webrtccommunication.dart';

enum ChatSignalingState {
  messageReceive,
  getAllMessages,
  update,
  userStatus,
  messageDelivered,
  typing,
  checkUnReadMessagesResponse
}

/*
 * callbacks for Signaling API.
 */
typedef ChatSignalingStateCallback = void Function(ChatSignalingState state, {Object? data});
typedef StreamStateCallback = void Function(MediaStream stream, String id);
typedef OtherEventCallback = void Function(dynamic event);
typedef DataChannelMessageCallback = void Function(RTCDataChannel dc, RTCDataChannelMessage data);
typedef DataChannelCallback = void Function(RTCDataChannel dc);

class ChatSignaling {
  // String toUsername;
  // String fromUsername;
  int? toUserId;
  int? fromUserId;
  ChatSignalingStateCallback? onStateChange;

  void setOnStateChange(ChatSignalingStateCallback onStateChange){
    this.onStateChange = onStateChange;
  }

  //SharedPreference sharedPreference = SharedPreference.getInstance();

  void initiateChat(int toUserId, int fromUserId, int id, int entityType) async {
    // var user = await sharedPreference.getUserDetail();
    // this.toUsername = toUsername;
    // this.fromUsername = user.username;
    this.toUserId = toUserId;
    //this.fromUserId = user.id;
    this.fromUserId = fromUserId;
    _send(Message(
        type: ChatSignalingConstants.initiateChat,
        data: {ChatSignalingConstants.to_user_id: toUserId, ChatSignalingConstants.from_user_id: fromUserId}));
  }

  void onMessage(message) async {
    Map<String, dynamic> mapData = message;
    var data = mapData['data'];
    //debugPrint("messageFromServer = $message");
    switch (mapData['type']) {
      case ChatSignalingConstants.receiveMessage:
        messageReceived(Chat(
            id: data['id'],
            fromUserId: data['to_user_id'],
            toUserId: data['from_user_id'],
            message: data['message'],
            status: data['status']));
        if (onStateChange != null) {
          onStateChange!(ChatSignalingState.messageReceive, data: Chat.fromJson(data));
        }
        break;
      case ChatSignalingConstants.update:
        if (onStateChange != null) {
          onStateChange!(ChatSignalingState.update, data: Chat.fromJson(data));
        }
        break;
      case ChatSignalingConstants.messageDelivered:
        if (onStateChange != null) {
          onStateChange!(ChatSignalingState.messageDelivered, data: Chat.fromJson(data));
        }
        break;
      case ChatSignalingConstants.getAllChats:
        if (onStateChange != null) {
          onStateChange!(ChatSignalingState.getAllMessages, data: AllChatData.fromJson(message));
        }
        break;
      case ChatSignalingConstants.isTyping:
        if (onStateChange != null) {
          onStateChange!(ChatSignalingState.typing, data: Chat.fromJson(data));
        }
        break;
      case ChatSignalingConstants.checkUnReadMessagesResponse:
        if (onStateChange != null) {
          onStateChange!(ChatSignalingState.checkUnReadMessagesResponse, data: true);
        }
        break;
      default:
        break;
    }
  }

  messageReceived(Chat chat) {
    _send(Message(type: ChatSignalingConstants.messageDelivered, data: {
      ChatSignalingConstants.to_user_id: chat.toUserId,
      ChatSignalingConstants.from_user_id: chat.fromUserId,
      ChatSignalingConstants.message: chat.message,
      ChatSignalingConstants.status: chat.status,
      ChatSignalingConstants.id: chat.id,
    }));
  }

  startTyping(Chat chat) {
    _send(Message(type: ChatSignalingConstants.messageDelivered, data: {
      ChatSignalingConstants.to_user_id: chat.toUserId,
      ChatSignalingConstants.from_user_id: chat.fromUserId,
      ChatSignalingConstants.isTyping: chat.id,
    }));
  }

  sendMessage(String message, String type, int id, int entityType, String mainName, String subName, int hospitalID) {
    _send(Message(type: ChatSignalingConstants.sendMessage, data: {
      ChatSignalingConstants.to_user_id: toUserId,
      ChatSignalingConstants.from_user_id: fromUserId,
      ChatSignalingConstants.message: message,
      ChatSignalingConstants.messageType: type,
      ChatSignalingConstants.entityID: id,
      ChatSignalingConstants.entityTypeID: entityType,
      ChatSignalingConstants.mainName: mainName,
      ChatSignalingConstants.subName: subName,
      ChatSignalingConstants.hospitalID: hospitalID,
    }));
  }

  sendStaticMessage(String message, String type, int id, int entityType) {
    _send(Message(type: ChatSignalingConstants.sendStaticMessage, data: {
      ChatSignalingConstants.to_user_id: toUserId,
      ChatSignalingConstants.from_user_id: fromUserId,
      ChatSignalingConstants.message: message,
      ChatSignalingConstants.messageType: type,
      ChatSignalingConstants.entityID: id,
      ChatSignalingConstants.entityTypeID: entityType,
    }));
  }

  checkUnReadMessages(int id, int entityType) {
    _checkUnReadMessages({
      ChatSignalingConstants.to_user_id: toUserId,
      ChatSignalingConstants.from_user_id: fromUserId,
      ChatSignalingConstants.entityID: id,
      ChatSignalingConstants.entityTypeID: entityType,
    });
  }

  _checkUnReadMessages(Object data) {
    debugPrint("message = $data");
    WebRtcCommunication.instance.sendData(socket_config.MessageType.checkUnReadMessages, data);
  }

  getAllMessage(int id, int entityType, int pageNum) {
    _getAllMessages({
      ChatSignalingConstants.to_user_id: toUserId,
      ChatSignalingConstants.from_user_id: fromUserId,
      ChatSignalingConstants.entityID: id,
      ChatSignalingConstants.entityTypeID: entityType,
      ChatSignalingConstants.pageNumber: pageNum,
    });
  }

  _send(Message message) {
    debugPrint("message = $message");
    WebRtcCommunication.instance.sendData(socket_config.MessageType.chat, message);
  }

  _getAllMessages(Object data) {
    debugPrint("message = $data");
    WebRtcCommunication.instance.sendData(socket_config.MessageType.getAllChats, data);
  }

  convertJson(List value) {
    return List<Chat>.from(value.map((e) => Chat.fromJson(e)));
  }
}
