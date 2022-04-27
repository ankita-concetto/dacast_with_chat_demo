import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:webrtccommunication_example/common/routes.dart';
import 'package:webrtccommunication_example/firebase_notification/firebase_notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp firebaseApp = await Firebase.initializeApp();
  debugPrint('${firebaseApp.options}');

  await FirebaseNotification().init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      enableLog: true,
      initialRoute: RouteName.root,
      theme: ThemeData(
          backgroundColor: Colors.white,
          appBarTheme: AppBarTheme(backgroundColor: Colors.blueGrey.shade800),
          primaryColor: Colors.blueGrey.shade900),
      getPages: Routes.routes,
      builder: (context, widget) {
        return SafeArea(
          top: Platform.isIOS ? false : false,
          bottom: Platform.isIOS ? false : true,
          child: widget ?? Container(),
        );
      },
    );
  }
}
