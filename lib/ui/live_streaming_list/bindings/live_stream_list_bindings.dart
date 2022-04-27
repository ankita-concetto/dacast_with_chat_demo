import 'package:get/get.dart';

import '../presentation/controller/live_streaming_list_controller.dart';

class LiveStreamingListBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LiveStreamingListController());
  }

}