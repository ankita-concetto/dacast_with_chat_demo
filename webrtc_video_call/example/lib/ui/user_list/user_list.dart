import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:webrtccommunication/utils/signaling_constants.dart';
import 'package:webrtccommunication_example/common/routes.dart';

class UserList extends GetView {
  TextEditingController myUserIdController = TextEditingController()
    ..text = '10';
  TextEditingController otherUserIdController = TextEditingController()
    ..text = '20';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: myUserIdController,
                decoration: const InputDecoration(
                  labelText: 'myUserId',
                  hintText: 'myUserId',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(
                height: 16,
              ),
              TextField(
                controller: otherUserIdController,
                decoration: const InputDecoration(
                  labelText: 'otherUserId',
                  hintText: 'otherUserId',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(
                height: 24,
              ),
              Material(
                color: Colors.blueGrey.shade800,
                child: InkWell(
                  splashColor: Colors.blueGrey.shade500,
                  onTap: () {
                    if (myUserIdController.text.isEmpty) return;
                    if (otherUserIdController.text.isEmpty) return;
                    Get.toNamed(
                      RouteName.ChatScreen,
                      arguments: {
                        'userId' : myUserIdController.text,
                        'otherUserId' : otherUserIdController.text
                      }
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Start Chatting',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
