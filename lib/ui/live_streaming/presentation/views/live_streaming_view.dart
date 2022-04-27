import 'dart:ui';

import 'package:decast_player_plugin/decast_player_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

import '../../../../models/chat_model.dart';
import '../../../common/common.dart';
import '../controller/live_streaming_controller.dart';

/*class LiveStreamingView extends StatefulWidget {
  const LiveStreamingView({Key? key}) : super(key: key);

  @override
  _LiveStreamingViewState createState() => _LiveStreamingViewState();
}

class _LiveStreamingViewState extends State<LiveStreamingView> {
  String viewType = 'com.example.test.dacast_demo/openDacastPlayer';
  Map<String, dynamic> creationParams = <String, dynamic>{};

  @override
  Widget build(BuildContext context) {
    return PlatformViewLink(
      viewType: viewType,
      surfaceFactory:
          (BuildContext context, PlatformViewController controller) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (PlatformViewCreationParams params) {
        return PlatformViewsService.initSurfaceAndroidView(
          id: params.id,
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          onFocus: () {
            params.onFocusChanged(true);
          },
        )
          ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
          ..create();
      },
    );
  }
}*/

class LiveStreamingView extends GetView<LiveStreamingController> {

  LiveStreamingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const DecastPlayerPlugin(),
          Positioned(
            top: 50,
            right: 20,
            child: _getChatIcon(),
          ),
          Positioned(
            child: Column(
              children: [
                _getChatMessageList(),
                const SizedBox(
                  height: 20,
                ),
                _getSendChatLayoutBox()
              ],
            ),
            bottom: 20,
            left: 10,
            right: 10,
          )
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
    return Expanded(
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

        ));
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
