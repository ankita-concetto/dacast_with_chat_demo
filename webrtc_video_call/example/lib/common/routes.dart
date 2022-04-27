import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:webrtccommunication_example/ui/chat/binding/chat_binding.dart';
import 'package:webrtccommunication_example/ui/chat/presentation/chat_screen.dart';
import 'package:webrtccommunication_example/ui/image_preview/image_preview_screen.dart';
import 'package:webrtccommunication_example/ui/user_list/user_list.dart';

class RouteName {
  // Base routes
  static const String root = "/UserList";
  static const String ChatScreen = "/ChatScreen";
  static const String ImagePreviewScreen = "/ImagePreviewScreen";
}

class Routes {
  static final routes = [
    GetPage(
      page: () => UserList(),
      name: RouteName.root,
    ),
    GetPage(
        name: RouteName.ChatScreen,
        page: () => ChatScreen(),
        binding: ChatBinding()),
    GetPage(
      name: RouteName.ImagePreviewScreen,
      page: () => ImagePreviewScreen(),
    )
  ];
}
