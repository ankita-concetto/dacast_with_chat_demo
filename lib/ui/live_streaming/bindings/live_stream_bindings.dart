import 'package:get/get.dart';

import '../presentation/controller/live_streaming_controller.dart';

class LiveStreamingBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LiveStreamingController());
  }

}