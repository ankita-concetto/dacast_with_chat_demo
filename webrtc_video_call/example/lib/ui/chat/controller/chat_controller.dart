import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:webrtccommunication/chat/chat_signaling.dart';
import 'package:webrtccommunication/utils/signaling_constants.dart';
import 'package:webrtccommunication/utils/socket_configuration.dart';
import 'package:webrtccommunication/webrtccommunication.dart';
import 'package:webrtccommunication_example/local_database/sqflite/sql_manager.dart';
import 'package:webrtccommunication_example/models/chat_model.dart';
import 'package:webrtccommunication_example/utils/utils.dart';

class ChatController extends SuperController {
  var socketStatus = "".obs;
  var userStatus = SignalingConstants.offline.obs;
  var userId; //id of logged in user
  var otherUserId; //id of person who will send message to
  var isSocketConnected = false;

  var screenVisibile = false;

  FocusNode focusNode = FocusNode();

  RxList<ChatModel> messages = (List<ChatModel>.of([])).obs;

  var isDatabaseInitialised = false.obs;

  late SQLManager _sqlManager;

  var messageCount = 0;

  final GroupedItemScrollController itemScrollController =
      GroupedItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  int page = 1;

  @override
  Future<void> onInit() async {
    super.onInit();
    debugPrint('${Get.arguments}');
    userId = int.parse(Get.arguments['userId']);
    otherUserId = int.parse(Get.arguments['otherUserId']);

    _sqlManager = SQLManager();
    await _sqlManager.init();

    await initDatabase();

    screenVisibile = true;

    initSocket();

    WebRtcCommunication.instance
        .setOnMessageCallback((messageType, data) async {
      switch (messageType) {
        case MessageType.addUser:
          if (isSocketConnected) {
            WebRtcCommunication.instance.sendData(MessageType.chat, {
              SignalingConstants.fromUserId: userId,
              SignalingConstants.toUserId: otherUserId
            });
            updateMessagesToSeen();
            updateMessagesToDelivered();
          }
          break;

        case MessageType.sendMessage:
          if (data.isNotEmpty) {
            Map<String, dynamic> json = jsonDecode(data);
            if (json.containsKey(SignalingConstants.message) &&
                json.containsKey(SignalingConstants.userId)) {
              ChatModel message = ChatModel(
                messageId: json[SignalingConstants.messageId],
                messageStatus: json[SignalingConstants.messageStatus],
                senderId: json[SignalingConstants.senderId].toString(),
                message: json[SignalingConstants.message],
                userId: json[SignalingConstants.userId].toString(),
                date: json[SignalingConstants.date],
                attachment: json[SignalingConstants.attachment],
              );
              messages.add(message);

              await _sqlManager.addMessage(message);

              showSnackBar(json[SignalingConstants.message]);
              if (userStatus.value != SignalingConstants.online) {
                changeUserStatus(SignalingConstants.online);
              }
              if (screenVisibile && isSocketConnected) {
                WebRtcCommunication.instance
                    .sendMessage(MessageType.messageStatus, {
                  SignalingConstants.userId: otherUserId,
                  SignalingConstants.senderId: userId,
                  SignalingConstants.message: json[SignalingConstants.message],
                  SignalingConstants.messageId:
                      json[SignalingConstants.messageId],
                  SignalingConstants.messageStatus: SignalingConstants.seen
                });
              }
              messages.refresh();
            }
          }
          break;

        case MessageType.messageStatus:
          if (data.isNotEmpty) {
            Map<String, dynamic> json = jsonDecode(data);
            if (json.containsKey(SignalingConstants.messageStatus)) {
              String messageStatus = json[SignalingConstants.messageStatus];
              if (messageStatus == SignalingConstants.seen) {
                messages.value.forEach(
                    (element) => element.messageStatus = messageStatus);

                await _sqlManager.updateAllMessagesStatus(messageStatus);
              } else {
                int messageId = json[SignalingConstants.messageId];
                messages.value
                    .where((p0) => p0.messageId == messageId)
                    .first
                    .messageStatus = messageStatus;

                await _sqlManager.updateMessageStatus(
                    messageStatus, messageId.toString());
              }
              debugPrint('messageDelivered update');
              messages.refresh();
            }
          }
          break;

        case MessageType.userStatus:
          if (data.isNotEmpty) {
            Map<String, dynamic> json = jsonDecode(data);
            if (json.containsKey(SignalingConstants.userId) &&
                json.containsKey(SignalingConstants.userStatus)) {
              if (userId == json[SignalingConstants.userId]) {
                debugPrint(
                    'userStatus: ${userStatus.value == SignalingConstants.offline}');
                if (userStatus.value == SignalingConstants.offline &&
                    json[SignalingConstants.userStatus] ==
                        SignalingConstants.online) {
                  changeUserStatus(SignalingConstants.online);
                }
                debugPrint(
                    'userStatus before check: ${json[SignalingConstants.userStatus]}');
                if (json[SignalingConstants.userStatus] !=
                    SignalingConstants.online) {
                  String timeStamp = json[SignalingConstants.userStatus];
                  String lastSeen = readTimeStamp(int.parse(timeStamp));
                  userStatus.value = "Last seen $lastSeen";
                  await _sqlManager.updateUserStatus(
                      otherUserId.toString(), timeStamp);
                } else {
                  userStatus.value = json[SignalingConstants.userStatus];
                  await _sqlManager.updateUserStatus(
                      otherUserId.toString(), userStatus.value);
                }
                update();
              }
            }
          }
          break;

        case MessageType.typing:
          if (data.isNotEmpty) {
            Map<String, dynamic> json = jsonDecode(data);
            if (json.containsKey(SignalingConstants.userId) &&
                json.containsKey(SignalingConstants.userStatus)) {
              userStatus.value = json[SignalingConstants.userStatus];
            }
          }
          break;
      }
    });

    WebRtcCommunication.instance.chatSignaling
        .setOnStateChange((state, {data}) {
      print('onStateChange: $state data: $data');
      showSnackBar(data as String, duration: const Duration(seconds: 1));
      switch (state) {
        case ChatSignalingState.getAllMessages:
          break;
        case ChatSignalingState.messageDelivered:
          break;
        case ChatSignalingState.messageReceive:
          break;
        case ChatSignalingState.userStatus:
          break;
        case ChatSignalingState.typing:
          break;
        case ChatSignalingState.checkUnReadMessagesResponse:
          break;
      }
    });

    itemPositionsListener.itemPositions.addListener(() async {
      var itemPosition = itemPositionsListener.itemPositions.value.first;
      debugPrint(
          '--> scroll positions ${itemPositionsListener.itemPositions.value.first.index}');
      debugPrint('--> messages length: ${messages.value.length}');
      if (itemPosition.index >= messages.value.length - 5 &&
          messageCount != 0 &&
          messageCount != messages.value.length &&
          messages.value.length >= 20) {
        debugPrint('--> ${itemPosition.index}');
        page++;
        List<ChatModel> newMessages = await _sqlManager.getMessages(
            userId.toString(), otherUserId.toString(), page);
        debugPrint('newMessages length: ${newMessages.length}');
        messages.value.insertAll(0, newMessages);
        messages.refresh();
      }
    });
  }

  void initSocket() {
    WebRtcCommunication.instance.init(
        host: '172.104.54.68',
        port: '3000',
        userId: userId,
        status: (state, {data}) {
          if (state == SocketConnectionStatus.CONNECTION_ESTABLISHED) {
            // socketStatus.value = 'Socket connected';
            // messageData.value = "Message received";
            // update();
            if (isSocketConnected == false) {
              isSocketConnected = true;
              showSnackBar('Socket connected',
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 1));

              sendUnSyncMessages();
            }
          } else if (state == SocketConnectionStatus.CONNECTION_DISCONNECTED) {
            isSocketConnected = false;
            // socketStatus.value = "Socket disconnected";
            // update();
            showSnackBar('Socket disconnected', backgroundColor: Colors.red);
          } else if (state == SocketConnectionStatus.ONMESSAGE) {
            debugPrint('state ONMESSAGE :$data');
          }
        });
  }

  void sendTyping(String status){
    if(isSocketConnected){
      WebRtcCommunication.instance.sendMessage(MessageType.typing, {
        SignalingConstants.userId: otherUserId,
        SignalingConstants.userStatus: status,
      });
    }
  }

  void changeUserStatus(String status) {
    if (isSocketConnected && Utils.USER_STATUS_ENABLE) {
      WebRtcCommunication.instance.sendData(MessageType.userStatus, {
        SignalingConstants.userId: otherUserId,
        SignalingConstants.userStatus: status
      });
    }
  }

  Future<void> sendMessage(String message) async {
    int messageId = generateRandomNumber();
    if (isSocketConnected) {
      WebRtcCommunication.instance.sendMessage(MessageType.sendMessage, {
        SignalingConstants.userId: otherUserId,
        SignalingConstants.senderId: userId,
        SignalingConstants.message: message,
        SignalingConstants.messageId: messageId,
        SignalingConstants.messageStatus: SignalingConstants.sent,
        SignalingConstants.date: Utils.date_format_yyyy_mm_dd_hh_mm_ss
            .format(DateTime.now().toUtc()),
        SignalingConstants.attachment: ""
      });
    }

    ChatModel chatMessage = ChatModel(
        userId: otherUserId.toString(),
        senderId: userId.toString(),
        message: message,
        messageId: messageId,
        messageStatus: SignalingConstants.sent,
        date: Utils.date_format_yyyy_mm_dd_hh_mm_ss
            .format(DateTime.now().toUtc()),
        attachment: "");

    messages.add(chatMessage);

    await _sqlManager.addMessage(chatMessage);
    update();
  }

  Future<void> sendFile(File file) async {
    int messageId = generateRandomNumber();

    ChatModel chatMessage = ChatModel(
      userId: otherUserId.toString(),
      senderId: userId.toString(),
      message: "",
      messageId: messageId,
      messageStatus: SignalingConstants.sent,
      date:
          Utils.date_format_yyyy_mm_dd_hh_mm_ss.format(DateTime.now().toUtc()),
      attachment: "",
      isAttchmentUploading: true,
    );

    messages.add(chatMessage);

    await _sqlManager.addMessage(chatMessage);
    update();

    Reference ref = FirebaseStorage.instance
        .ref()
        .child('attachments')
        .child('/IMAGE_${DateTime.now().millisecondsSinceEpoch}.jpg');

    UploadTask? task = await uploadFile(file, ref);
    debugPrint('after uploadFile()');
    task!.whenComplete(() async {
      debugPrint("task whenComplete");
      await Future.delayed(const Duration(seconds: 5));
      final url = await ref.getDownloadURL();
      debugPrint('url:$url');
      if (url.isNotEmpty) {
        ChatModel chat = messages.value
            .toList()
            .where((element) => element.messageId == messageId)
            .first;
        chat.isAttchmentUploading = false;
        chat.attachment = url;

        await _sqlManager.updateMessage(chat);
        if (isSocketConnected) {
          WebRtcCommunication.instance.sendMessage(MessageType.sendMessage, {
            SignalingConstants.userId: otherUserId,
            SignalingConstants.senderId: userId,
            SignalingConstants.message: "",
            SignalingConstants.messageId: messageId,
            SignalingConstants.messageStatus: SignalingConstants.sent,
            SignalingConstants.date: Utils.date_format_yyyy_mm_dd_hh_mm_ss
                .format(DateTime.now().toUtc()),
            SignalingConstants.attachment: url,
          });
        }
        messages.refresh();
        update();
      }
    });
  }

  Future<UploadTask?> uploadFile(File file, Reference ref) async {
    UploadTask uploadTask;

    uploadTask = ref.putFile(File(file.path));
    return Future.value(uploadTask);
  }

  void getAllMessages() {
    WebRtcCommunication.instance.chatSignaling.getAllMessage(userId, 0, 1);
  }

  @override
  void onDetached() async {}

  @override
  Future<void> onClose() async {
    await WebRtcCommunication.instance.close();
    debugPrint('onDetached');
    super.onClose();
  }

  @override
  void onInactive() {}

  @override
  void onPaused() {
    changeUserStatus(DateTime.now().toUtc().millisecondsSinceEpoch.toString());
    screenVisibile = false;
  }

  @override
  void onResumed() {
    screenVisibile = true;
    changeUserStatus(SignalingConstants.online);
    updateMessagesToSeen();
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

  generateRandomNumber() {
    return Random().nextInt(99999);
  }

  String readTimeStamp(int timeStamp) {
    var now = DateTime.now().toUtc();
    var date = DateTime.fromMillisecondsSinceEpoch(timeStamp, isUtc: true);
    var diff = now.difference(date);
    var time = '';
    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      // time = diff.inHours.toString()+'today at ' + format.format(date);
      if (diff.inHours >= 2) {
        time = "${diff.inHours} hours ago";
      } else if (diff.inHours >= 1) {
        time = "${diff.inHours} hour ago";
      } else if (diff.inMinutes >= 2) {
        time = "${diff.inMinutes} minutes ago";
      } else if (diff.inMinutes >= 1) {
        time = "${diff.inMinutes} minute ago";
      } else if (diff.inSeconds >= 3) {
        time = "${diff.inSeconds} seconds ago";
      } else {
        time = "Just now";
      }
    } else if (diff.inDays > 0 && diff.inDays < 7) {
      if (diff.inDays == 1) {
        time = diff.inDays.toString() + ' DAY AGO';
      } else {
        time = diff.inDays.toString() + ' DAYS AGO';
      }
    } else {
      if (diff.inDays == 7) {
        time = (diff.inDays / 7).floor().toString() + ' WEEK AGO';
      } else {
        time = (diff.inDays / 7).floor().toString() + ' WEEKS AGO';
      }
    }
    return time;
  }

  void updateMessagesToSeen() {
    if (isSocketConnected) {
      WebRtcCommunication.instance.sendMessage(MessageType.messageStatus, {
        SignalingConstants.userId: otherUserId,
        SignalingConstants.senderId: userId,
        SignalingConstants.message: '',
        SignalingConstants.messageId: 0,
        SignalingConstants.messageStatus: SignalingConstants.seen
      });
    }
  }

  Future<void> updateMessagesToDelivered() async {
    messages.value.forEach((element) {
      if (element.messageStatus == SignalingConstants.sent &&
          userStatus.value == SignalingConstants.online) {
        element.messageStatus = SignalingConstants.seen;
      } else if (element.messageStatus == SignalingConstants.sent) {
        element.messageStatus = SignalingConstants.delivered;
      }
    });

    if (userStatus.value == SignalingConstants.online) {
      await _sqlManager.updateMessagesSentToSeen(
          userId.toString(), SignalingConstants.seen);
    } else {
      await _sqlManager.updateMessagesSentToSeen(
          userId.toString(), SignalingConstants.delivered);
    }

    messages.refresh();
  }

  initDatabase() async {
    debugPrint('-->Time ${DateTime.now()}:');
    messagesCount();
    messages.value = await _sqlManager.getMessages(
        userId.toString(), otherUserId.toString(), page);
    isDatabaseInitialised.value = true;

    messages.refresh();
    debugPrint(
        '-->Time ${DateTime.now()}: InitDatabase done: ${messages.value.length}');

    String status = SignalingConstants.offline;
    status = await _sqlManager.getUserStatus(otherUserId.toString());

    if (status != SignalingConstants.online &&
        status != SignalingConstants.offline) {
      String timeStamp = status;
      String lastSeen = readTimeStamp(int.parse(timeStamp));
      userStatus.value = "Last seen $lastSeen";
    } else {
      userStatus.value = SignalingConstants.offline;
    }
    userStatus.refresh();
  }

  void sendUnSyncMessages() {
    List<ChatModel> unSyncMessages = messages.value
        .where((element) => element.messageStatus == SignalingConstants.sent)
        .toList();
    debugPrint('unSyncMsg: ${unSyncMessages.length}');
    if (unSyncMessages.isNotEmpty) {
      if (isSocketConnected) {
        unSyncMessages.forEach((element) {
          WebRtcCommunication.instance.sendMessage(MessageType.sendMessage, {
            SignalingConstants.userId: element.userId,
            SignalingConstants.senderId: element.senderId,
            SignalingConstants.message: element.message,
            SignalingConstants.messageId: element.messageId,
            SignalingConstants.messageStatus: element.messageStatus,
            SignalingConstants.date: element.date,
            SignalingConstants.attachment: element.attachment
          });
        });
      }
    }
  }

  void messagesCount() async {
    int count = await _sqlManager.getMessagesCount(
        userId.toString(), otherUserId.toString());
    messageCount = count;
    debugPrint('messageCount--> $count');
  }
}
