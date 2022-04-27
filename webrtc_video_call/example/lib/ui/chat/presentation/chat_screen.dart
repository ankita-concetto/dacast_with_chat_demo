import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:webrtccommunication/utils/signaling_constants.dart';
import 'package:webrtccommunication_example/common/routes.dart';
import 'package:webrtccommunication_example/models/chat_model.dart';
import 'package:webrtccommunication_example/ui/chat/controller/chat_controller.dart';

import '../../../utils/strings.dart';
import '../../../utils/utils.dart';

class ChatScreen extends GetView<ChatController> {
  TextEditingController messageController = TextEditingController();
  Duration? previousHeaderForDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade800,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.otherUserId.toString(),
              style: const TextStyle(fontSize: 16),
            ),
            Utils.USER_STATUS_ENABLE
                ? const SizedBox(
                    height: 4,
                  )
                : const SizedBox(),
            Utils.USER_STATUS_ENABLE
                ? Obx(() => Text(
                      controller.userStatus.value,
                      style: const TextStyle(fontSize: 12),
                    ))
                : const SizedBox()
          ],
        ),
        actions: [
          GestureDetector(
            child: const Icon(Icons.refresh),
            onTap: () {
              if (!controller.isSocketConnected) {
                controller.initSocket();
              }
            },
          )
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Obx(
                  () => Expanded(
                    child: StickyGroupedListView(
                      shrinkWrap: true,
                      itemScrollController: controller.itemScrollController,
                      itemPositionsListener: controller.itemPositionsListener,
                      reverse: true,
                      elements: controller.messages.value,
                      groupBy: (ChatModel element) {
                        var formmattedDate = Utils
                            .date_format_yyyy_mm_dd_hh_mm_ss
                            .parse(element.date!);
                        var date =
                            Utils.date_format_dd_mm_yyyy.format(formmattedDate);
                        return date;
                      },
                      order: StickyGroupedListOrder.DESC,
                      stickyHeaderBackgroundColor: Colors.white,
                      floatingHeader: true,
                      groupSeparatorBuilder: (ChatModel element) {
                        var formmattedDate = Utils
                            .date_format_yyyy_mm_dd_hh_mm_ss
                            .parse(element.date!);
                        var now = DateTime.now();
                        var diff = now.difference(formmattedDate);
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 24,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: Center(
                                child: Text(
                                  diff.inDays == 0
                                      ? "Today"
                                      : diff.inDays == 1
                                          ? "Yesterday"
                                          : Utils.date_format_mmmm_dd_yyyy
                                              .format(formmattedDate),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade400,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(16))),
                            ),
                          ],
                        );
                      },
                      itemBuilder: (context, ChatModel chat) {
                        /*List<ChatModel> list =
                        controller.messages.reversed.toList();*/
                        return Column(
                          children: [chatMessageWidget(chat)],
                        );
                      },
                      separator: const Divider(
                        height: 8,
                        thickness: 0,
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 8),
                    ),
                  ),
                ),
                SizedBox(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: SizedBox(
                          child: Card(
                            color: Colors.blueGrey.shade900,
                            margin: const EdgeInsets.only(
                                left: 2, right: 2, bottom: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: TextFormField(
                              controller: messageController,
                              focusNode: controller.focusNode,
                              textAlignVertical: TextAlignVertical.center,
                              keyboardType: TextInputType.multiline,
                              maxLines: 5,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                              cursorColor: Colors.white,
                              minLines: 1,
                              onChanged: (value) {
                                if (value.length == 1) {
                                  controller.sendTyping(SignalingConstants.typing);
                                } else if (value.isEmpty) {
                                  controller.sendTyping(SignalingConstants.online);
                                }
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: Strings.typeMessage,
                                hintStyle: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.attach_file,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        showModalBottomSheet(
                                            backgroundColor: Colors.transparent,
                                            context: context,
                                            builder: (builder) =>
                                                bottomSheetForDocAttachment());
                                      },
                                    ),
                                  ],
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 16),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: ClipOval(
                          child: Material(
                            color: Colors.blueGrey.shade800,
                            child: InkWell(
                              splashColor: Colors.blueGrey.shade500,
                              onTap: () {
                                if (messageController.text.isEmpty) return;
                                /*controller.sendMessage(
                                    messageController.text.toString());
                                messageController.clear();*/
                                // controller.getAllMessages();
                              },
                              child: const Icon(
                                Icons.send,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                    ],
                  ),
                )
              ],
            ),
            Obx(
              () => Visibility(
                visible: !controller.isDatabaseInitialised.value,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  messageReceivedWidget() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomRight,
      children: const [
        Icon(
          Icons.check,
          color: Colors.white,
          size: 10,
        ),
        Positioned(
          child: Icon(
            Icons.check,
            color: Colors.white,
            size: 10,
          ),
          right: 4,
        ),
      ],
    );
  }

  messageSentWidget() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomRight,
      children: const [
        Icon(
          Icons.watch_later_outlined,
          color: Colors.white,
          size: 10,
        ),
      ],
    );
  }

  messageDeliveredWidget() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomRight,
      children: const [
        Icon(
          Icons.check,
          color: Colors.white,
          size: 10,
        ),
      ],
    );
  }

  messageSeenWidget() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomRight,
      children: const [
        Icon(
          Icons.check,
          color: Colors.blue,
          size: 10,
        ),
        Positioned(
          child: Icon(
            Icons.check,
            color: Colors.blue,
            size: 10,
          ),
          right: 4,
        ),
      ],
    );
  }

  Duration readTimeStamp(String timeStamp) {
    var now = DateTime.now();
    var date =
        DateTime.fromMillisecondsSinceEpoch(int.parse(timeStamp), isUtc: true);
    var diff = now.difference(date);
    return diff;
  }

  Widget chatMessageWidget(ChatModel chat) {
    var formattedDate =
        Utils.date_format_yyyy_mm_dd_hh_mm_ss.parse(chat.date!, true);
    var time = Utils.date_format_hh_mm_a.format(formattedDate.toLocal());
    return Align(
      alignment: chat.userId != controller.userId.toString()
          ? Alignment.topRight
          : Alignment.topLeft,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.blueGrey.shade800,
            borderRadius: const BorderRadius.all(Radius.circular(16))),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            chat.attachment != null && chat.attachment!.isNotEmpty
                ? SizedBox(
                    height: Get.height * 0.2,
                    width: Get.width * 0.5,
                    child: GestureDetector(
                      onTap: () {
                        Get.toNamed(RouteName.ImagePreviewScreen,
                            arguments: {'image': chat.attachment});
                      },
                      child: chat.attachment!.startsWith("http")
                          ? Hero(
                              tag: chat.attachment!,
                              child: CachedNetworkImage(
                                imageUrl: chat.attachment!,
                                height: Get.height * 0.2,
                                width: Get.width * 0.5,
                                placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(
                                  color: Colors.white,
                                )),
                                errorWidget: (context, url, errro) =>
                                    const Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.browse_gallery,
                            ),
                    ),
                  )
                : chat.isAttchmentUploading == true
                    ? SizedBox(
                        height: Get.height * 0.2,
                        width: Get.width * 0.5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              Strings.uploading,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            )
                          ],
                        ),
                      )
                    : const SizedBox(),
            Text(
              '${chat.message}',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(
              height: 4,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(
                  width: 8,
                ),
                Text(
                  time,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                const SizedBox(
                  width: 4,
                ),
                if (chat.messageStatus == SignalingConstants.delivered) ...[
                  chat.userId != controller.userId.toString()
                      ? messageDeliveredWidget()
                      : const SizedBox()
                ] else if (chat.messageStatus ==
                    SignalingConstants.received) ...[
                  chat.userId != controller.userId.toString()
                      ? messageReceivedWidget()
                      : const SizedBox()
                ] else if (chat.messageStatus == SignalingConstants.seen) ...[
                  chat.userId != controller.userId.toString()
                      ? messageSeenWidget()
                      : const SizedBox()
                ] else ...[
                  chat.userId != controller.userId.toString()
                      ? messageSentWidget()
                      : const SizedBox()
                ],
                const SizedBox(
                  width: 4,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomSheetForDocAttachment() {
    return SizedBox(
      width: Get.width,
      child: Card(
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  /*iconForAttachment(
                      Icons.insert_drive_file, Colors.indigo, Strings.document),*/
                  iconForAttachment(
                      Icons.camera_alt, Colors.pink, Strings.camera),
                  iconForAttachment(
                      Icons.insert_photo, Colors.purple, Strings.gallery)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget iconForAttachment(IconData icons, Color color, String text) {
    return InkWell(
      onTap: () async {
        Get.back();
        if (text == Strings.document) {
        } else if (text == Strings.camera || text == Strings.gallery) {
          XFile? file = await ImagePicker().pickImage(
            source: text == Strings.camera
                ? ImageSource.camera
                : ImageSource.gallery,
            imageQuality: 50,
          );
          if (file != null) {
            final dir = await path_provider.getTemporaryDirectory();
            File compressedFile = await testCompressAndGetFile(
                file,
                dir.absolute.path +
                    "/IMAGE_${DateTime.now().millisecondsSinceEpoch.toString()}.jpg");
            //controller.sendFile(compressedFile);
          }
        }
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(
              icons,
              size: 30,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            text,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<File> testCompressAndGetFile(XFile? file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file!.path,
      targetPath,
      quality: 50,
    );
    return result!;
  }
}
