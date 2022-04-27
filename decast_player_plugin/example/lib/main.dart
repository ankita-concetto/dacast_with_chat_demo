import 'dart:async';
import 'dart:ui';

import 'package:decast_player_plugin/decast_player_plugin.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isChatInitate = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
        setState(() {
          isChatInitate = !isChatInitate;
        });
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
    return IconButton(onPressed: () {}, icon: const Icon(Icons.send, size: 25, color: Color(0xffffc800)));
  }

  Widget _getChatMessageList() {
    return Stack(
      children: [
        SizedBox(
          height: 200,
          child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return _getChatLayout();
              }),
        ),
      ],
    );
  }

  Widget _getChatLayout() {
    return Container(
      margin: const EdgeInsets.only(top: 5, bottom: 5),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/images/profile_image.jpeg'),
            ),
            const SizedBox(width: 10,),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Ankita Rana",style: TextStyle(color: Colors.white, fontSize: 12),),
                SizedBox(height: 5,),
                Text("Nice Singing",style: TextStyle(color: Colors.white, fontSize: 10),),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _onPlatformViewCreated(int id) {
    /*if (widget.onTextViewCreated == null) {
      return;
    }
    widget.onTextViewCreated(new TextViewController._(id));*/
  }
}
