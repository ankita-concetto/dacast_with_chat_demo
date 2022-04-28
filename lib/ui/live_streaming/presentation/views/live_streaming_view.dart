import 'dart:async';
import 'dart:ui';

import 'package:decast_player_plugin/decast_player_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import '../../../../models/chat_model.dart';
import '../controller/live_streaming_controller.dart';

/*
class LiveStreamingView extends StatefulWidget {

  LiveStreamingView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }

}
*/

class LiveStreamingView extends StatefulWidget {
  const LiveStreamingView({Key? key}) : super(key: key);

  @override
  State<LiveStreamingView> createState() => _LiveStreamingViewState();
}

class _LiveStreamingViewState extends State<LiveStreamingView> {
  final controller = Get.find<LiveStreamingController>();
  final _formKey = GlobalKey<FormState>();
  late StreamSubscription<bool> keyboardSubscription;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var bottom = MediaQuery.of(context).viewInsets.bottom;
    print("bottom = $bottom");
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const DecastPlayerPlugin(),
          Obx(() => AnimatedPositioned(
            duration: const Duration(milliseconds: 100),
            bottom : MediaQuery.of(context).viewInsets.bottom != 0.0 ? MediaQuery.of(context).viewInsets.bottom + 20 : 60.0,
            child: Column(
              children: [
                _getChatMessageList(),
                const SizedBox(
                  height: 20,
                ),
                _getSendChatLayoutBox()
              ],
            ),
            left: 10,
            right: 10,
          )),
        ],
      ),
    );
  }

  Widget _getChatIcon() {
    return InkWell(
      child: Image.asset(
        'assets/images/chat.png',
        height: 30,
        width: 30,
        color: const Color(0xffffc800),
      ),
      onTap: () {
        controller.isChatInitiate.value = !controller.isChatInitiate.value;
      },
    );
  }

  Widget _getSendChatLayoutBox() {
    return Container(
      padding : const EdgeInsets.fromLTRB(20, 0, 10, 0),
      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(40)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [_getChatTextField() , _getSendIcon()],
      ),
    );
  }

  Widget _getChatTextField() {
    return Form(
      key: _formKey,
      child: Expanded(
          child: TextFormField(
            controller: controller.messageController.value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w300,
            ),
            decoration: const InputDecoration(
                hintText: 'Enter message here...',
                hintStyle: TextStyle(
                  color: Colors.white60,
                  fontWeight: FontWeight.w300,
                ),
                border: InputBorder.none
            ),

          )),
    );
  }

  Widget _getSendIcon() {
    return IconButton(onPressed: () {
      if (controller.messageController.value.text.isEmpty) return;
      controller.sendMessage(
          controller.messageController.value.text.toString());
      controller.messageController.value.clear();
    }, icon: const Icon(Icons.send, size: 25, color: Color(0xffffc800)));
  }

  Widget _getChatMessageList() {
    return Stack(
      children: [
        Obx(
              () => SizedBox(
            height: 200,
            child: ListView.builder(
                controller: controller.controller,
                itemCount: controller.streamingMessages.value.length,
                reverse: true,
                itemBuilder: (context, index) {
                  return _getChatLayout(controller.streamingMessages.value[index]);
                }),
          ),
        )
      ],
    );
  }

  Widget _getChatLayout(ChatModel value) {
    return Container(
      margin: const EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/images/profile_image.jpeg'),
          ),
          const SizedBox(width: 10,),
          Expanded(child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value.name ?? '',style: const TextStyle(color: Colors.white, fontSize: 12),),
              const SizedBox(height: 5,),
              Text(value.message.toString(),style: const TextStyle(color: Colors.white, fontSize: 10),)
            ],
          ))
        ],
      ),
    );
  }

}

