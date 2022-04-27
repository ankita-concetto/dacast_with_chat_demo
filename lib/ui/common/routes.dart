import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../live_streaming/bindings/live_stream_bindings.dart';
import '../live_streaming/presentation/views/live_streaming_view.dart';
import '../live_streaming_list/bindings/live_stream_list_bindings.dart';
import '../live_streaming_list/presentation/views/live_streaming_list_view.dart';

class RouteName {
  static const init = root;

  // Base routes
  static const String root = '/';
  static const String streamingPage = '/streaming';
  static const String liveStreamingPage = '/liveStreaming';
}

class Routes {
  static final routes = [
    GetPage(
        page: () => LiveStreamingView(),
        name: RouteName.streamingPage,
        binding: LiveStreamingBindings()),
    GetPage(
        page: () => LiveStreamingListView(),
        name: RouteName.liveStreamingPage,
        binding: LiveStreamingListBindings())
  ];
  static final commonRoutes = <String, WidgetBuilder>{};
}
