import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_speed_test/callbacks_enum.dart';
import 'package:internet_speed_test/internet_speed_test.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:webrtccommunication/utils/signaling_constants.dart';
import 'package:webrtccommunication/utils/socket_configuration.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:webrtccommunication/webrtccommunication.dart';
import '../../../../models/chat_model.dart';
import '../../../common/common.dart';

class LiveStreamingController extends SuperController {
  RxBool isChatInitiate = false.obs;
  final messageController = TextEditingController().obs;
  final ScrollController controller = ScrollController();
  final internetSpeedTest = InternetSpeedTest();

  var socketStatus = "".obs;
  var userStatus = SignalingConstants.offline.obs;
  var userId; //id of logged in user
  var otherUserId; //id of person who will send message to
  var name; //id of person who will send message to
  var isSocketConnected = false;

  var screenVisibile = false;

  FocusNode focusNode = FocusNode();

  RxList<ChatModel> streamingMessages = (List<ChatModel>.of([])).obs;

  var isDatabaseInitialised = false.obs;

  var messageCount = 0;

  int page = 1;

  RxDouble animatedPosition = 50.0.obs;
  final GroupedItemScrollController itemScrollController =
  GroupedItemScrollController();
  final ItemPositionsListener itemPositionsListener =
  ItemPositionsListener.create();

  @override
  Future<void> onInit() async {
    super.onInit();
    debugPrint('${Get.arguments}');
    userId = Get.arguments['userId'];
    otherUserId = 662;
    name = Get.arguments['name'];

    screenVisibile = true;

    initSocket();

    //Receive calls from socket.
    WebRtcCommunication.instance
        .setOnMessageCallback((messageType, data) async {
      switch (messageType) {
        case MessageType.addUser:
          if (isSocketConnected) {
          }
          break;
        case MessageType.sendMessage:
          if (data.isNotEmpty) {
            Map<String, dynamic> json = jsonDecode(data);
            if (json.containsKey(SignalingConstants.body) &&
                json.containsKey(SignalingConstants.userId)) {
              ChatModel message = ChatModel(
                messageId: json[SignalingConstants.messageId],
                messageStatus: json[SignalingConstants.messageStatus],
                senderId: json[SignalingConstants.senderId].toString(),
                message: json[SignalingConstants.body],
                userId: json[SignalingConstants.userId].toString(),
                date: json[SignalingConstants.date],
                name: json[SignalingConstants.name],
                attachment: json[SignalingConstants.attachment],
              );
              streamingMessages.insert(0,message);

              controller.animateTo(
                0,
                duration: const Duration(seconds: 1),
                curve: Curves.fastOutSlowIn,
              );

              showSnackBar(json[SignalingConstants.body]);
              streamingMessages.refresh();
            }
          }
          break;
        case MessageType.videoCall:
          break;
        case MessageType.chat:
          break;
        case MessageType.checkUnReadMessages:
          break;
        case MessageType.getAllChats:
          break;
        case MessageType.message:
          break;
        case MessageType.userStatus:
          break;
        case MessageType.messageStatus:
          break;
        case MessageType.sent:
          break;
        case MessageType.delivered:
          break;
        case MessageType.received:
          break;
        case MessageType.seen:
          break;
        case MessageType.typing:
          break;
      }
    });
  }

  void initSocket() {
    WebRtcCommunication.instance.init(
        host: '172.104.54.68',
        port: '3000',
        userId: userId,
        receiverId: otherUserId,
        status: (state, {data}) {
          if (state == SocketConnectionStatus.CONNECTION_ESTABLISHED) {
            if (isSocketConnected == false) {
              isSocketConnected = true;
              /*showSnackBar('Socket connected',
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 1));*/
            }
          } else if (state == SocketConnectionStatus.CONNECTION_DISCONNECTED) {
            isSocketConnected = false;
            /*showSnackBar('Socket disconnected', backgroundColor: Colors.red);*/
          } else if (state == SocketConnectionStatus.ONMESSAGE) {
            debugPrint('state ONMESSAGE :$data');
          }
        });
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
    super.onClose();
  }

  //send Message to socket
  Future<void> sendMessage(String message) async {
    int messageId = generateRandomNumber();
    if (isSocketConnected) {
      WebRtcCommunication.instance.sendMessage(MessageType.sendMessage, {
        SignalingConstants.userId: userId,
        SignalingConstants.receiverId: otherUserId,
        SignalingConstants.name: name,
        SignalingConstants.type: 'message',
        SignalingConstants.actionType: 'sendMessage',
        SignalingConstants.body: message,
        SignalingConstants.timestamp: Utils.date_format_yyyy_mm_dd_hh_mm_ss
            .format(DateTime.now().toUtc())
      });
    }

    ChatModel chatMessage = ChatModel(
        userId: otherUserId.toString(),
        senderId: userId.toString(),
        message: message,
        messageId: messageId,
        messageStatus: SignalingConstants.sent,
        name: name,
        date: Utils.date_format_yyyy_mm_dd_hh_mm_ss
            .format(DateTime.now().toUtc()),
        attachment: "");

    streamingMessages.insert(0,chatMessage);

    controller.animateTo(
      0,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
    update();
  }

  generateRandomNumber() {
    return Random().nextInt(99999);
  }

  showSnackBar(
      String message, {
        textColor = Colors.white,
        backgroundColor = Colors.blue,
        duration = const Duration(seconds: 1),
      }) {
    Get.snackbar('Chat App', message,
        colorText: textColor,
        backgroundColor: backgroundColor,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        duration: duration);
  }

}