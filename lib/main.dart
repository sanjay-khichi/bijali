import 'dart:io';
import 'dart:math';

import 'package:bijali/screen/view/dashboard_view/video_player_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_player/video_player.dart';


import 'screen/controller/dashboard_controller.dart';
import 'screen/view/auth/auth_view.dart';
import 'utils/colors.dart';
import 'utils/sound.dart';

//ca-app-pub-3719084056205826~9954165381 app Id
//ca-app-pub-3719084056205826/6798315160 nativeaddunit
DashBoardController videoController = Get.put(DashBoardController());
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  await Firebase.initializeApp();
}
fcmNotification() {
  try {
    FirebaseMessaging.instance.requestPermission().then((value) async {
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message)async {

      });

    });
  } catch (e) {
    throw e;
  }
}
void main() async{
  //videoController.performBatchOperation();
  WidgetsFlutterBinding?.ensureInitialized();
  await Firebase.initializeApp();
  fcmNotification();
  getSoundInfo();
  MobileAds.instance.initialize();
  if(FirebaseAuth.instance.currentUser != null) {
    print("========loadData=======");
    videoController.fetchCoontent();
  }
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //plwase
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: generateMaterialColor(ColorConstants.appThemeColor),
      ),
    //  home: const Test(),
      home: AuthChecker(),

    );
  }


}

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  VideoPlayerController? videoPlayerController;
  @override
  void initState() {
    // TODO: implement initState
    videoPlayerController = VideoPlayerController.file(File("/storage/emulated/0/Documents/coontent/coontent/nbtqxTDRc9faDjQeiP6J60wNDPx2_1687056861662.mp4"))
      ..initialize().then((value) {

        if(mounted){

          videoPlayerController!.seekTo(Duration.zero);
          videoPlayerController!.play();
        //  videoPlayerController!.setVolume( sound);
          videoPlayerController!.setLooping(true);
        //  playerController.setIsLoading = false;
        }

      });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return VideoPlayer(videoPlayerController!);
  }
}

