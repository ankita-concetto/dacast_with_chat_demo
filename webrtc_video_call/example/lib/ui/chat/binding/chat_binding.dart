import 'package:get/get.dart';
import 'package:webrtccommunication_example/ui/chat/controller/chat_controller.dart';

class ChatBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<ChatController>(() => ChatController());
  }
}