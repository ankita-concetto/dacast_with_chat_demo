import 'package:dacast_with_chat_demo/ui/app_theme.dart';
import 'package:dacast_with_chat_demo/ui/common/common.dart';
import 'package:dacast_with_chat_demo/ui/common/routes.dart';
import 'package:dacast_with_chat_demo/ui/string.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'di/app_component_base.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: RouteName.init,
      getPages: Routes.routes,
      home: const MyHomePage(title: 'Dacast Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController nameController = TextEditingController();
  void _joinStream() async {
    var  data = {
      "name" : nameController.text,
    };
    Get.toNamed(RouteName.liveStreamingPage, arguments: data);
  }

  void _sendNetworkStatus(bool? networkStatus) async {
    //await platform.invokeMethod('NetworkStream', {'arguments': networkStatus});
  }

  @override
  void initState() {
    AppComponentBase.getInstance()?.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _appTheme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller : nameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter Your Name',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () {
                      _joinStream();
                    },
                    child: const Text(
                      'Join Live Streaming app',
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
                                style: _appTheme.customTextStyle(fontSize: 15, color: _appTheme.whiteColor))),
                      )),
                );
              }),
        ],
      ),
    );
  }
}
