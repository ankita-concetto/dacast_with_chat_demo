import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../../../../di/app_component_base.dart';
import '../../../app_theme.dart';
import '../../../common/common.dart';
import '../../../common/routes.dart';
import '../../../string.dart';
import '../controller/live_streaming_list_controller.dart';


class LiveStreamingListView extends GetView<LiveStreamingListController> {

  const LiveStreamingListView({Key? key}) : super(key: key);

  void _playStream() async {
    var  data = {
      "name" : controller.name.value,
      "userId" : controller.generateRandomNumber()
    };
    Get.toNamed(RouteName.streamingPage, arguments: data);
  }

  @override
  Widget build(BuildContext context) {
    final _appTheme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Live Channels'),
      ),
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Test Stream Demo',
                ),
                const Spacer(),
                ElevatedButton(onPressed: () {
                  _playStream();
                }, child: const Text(
                  'Play',
                ))
              ],
            ),
          ),
          StreamBuilder<bool?>(
              initialData: true,
              stream: AppComponentBase.getInstance()?.getNetworkManager().internetConnectionStream,
              builder: (context, snapshot) {
                return SafeArea(
                  child: AnimatedContainer(
                      height: snapshot.data as bool ? 0 : 40,
                      duration: Utils.animationDuration,
                      color: _appTheme.redColor,
                      child: Material(
                        type: MaterialType.transparency,
                        child: Center(
                            child: Text(StringConstants.noInternetConnection,
                                style: _appTheme.customTextStyle(
                                    fontSize: 15,
                                    color: _appTheme.whiteColor))),
                      )),
                );
              }),
        ],
      ),
    );
  }

}
