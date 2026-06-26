import 'package:app_version_update/app_version_update.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../utils/colors.dart';
import '../../controller/dashboard_controller.dart';
import '../add_post_view/add_post_view.dart';
import '../profile_view/profile_view.dart';
import 'dashboard_view.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  DashBoardController videoController = Get.find();

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {



    //return HomeNavigator();
    return StreamBuilder<bool>(
      stream: videoController.isLoadingStream,
      builder: (context, AsyncSnapshot<bool> snapshot) {
        print("==========snapshot data==========");
        print(snapshot.data);
        if(snapshot.data ==true){
          return HomeNavigator();
        }else{
          return Scaffold(body: Container(color: Colors.black,child: Center(child: Image.asset("assets/bijali.gif",height: MediaQuery.of(context).size.height,width: MediaQuery.of(context).size.width,fit: BoxFit.fill,)),),);
        }
      },);



  }
}
class HomeNavigator extends StatefulWidget {
  const HomeNavigator({Key? key}) : super(key: key);

  @override
  State<HomeNavigator> createState() => _HomeNavigatorState();
}

class _HomeNavigatorState extends State<HomeNavigator> {

  DashBoardController dashBoardController = Get.find();

  Widget callPage(int currentIndex) {

    switch (currentIndex) {
      case 0:
        return DashBoardView();
      case 1:
        //return SizedBox();
        return AddPostView();

      case 2:
        return ProfileView(FirebaseAuth.instance.currentUser!.uid,true);

      default:
        return ProfileView(FirebaseAuth.instance.currentUser!.uid,true);
    }
  }
  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: WillPopScope(
        onWillPop: ()async{
          if(dashBoardController.getCurrentIndex == 0){
            SystemNavigator.pop();
            return await true;
          }
          else{
            setState(() {
              dashBoardController.setCurrentIndex = 0;

            });
            return await false;
          }

        },
        child: Scaffold(

          body: Obx(()=>callPage(dashBoardController.getCurrentIndex)),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor:ColorConstants.appThemeColor ,
              currentIndex:dashBoardController.getCurrentIndex ,
              onTap: (int val) {
                //returns tab id which is user tapped
                  dashBoardController.setCurrentIndex =val;

              },
              items: [

                BottomNavigationBarItem(

                  backgroundColor:ColorConstants.appThemeColor ,
                  icon: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: SvgPicture.asset("assets/icons/home.svg",),
                  ),
                  label: 'home',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: SvgPicture.asset("assets/icons/add.svg"),
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: SvgPicture.asset("assets/icons/user.svg"),
                  ),
                  label: '',
                ),
              ],
            )


        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    dashBoardController.fetchMyDetails(
        FirebaseAuth.instance.currentUser!.uid);
    checkUpdate();
    super.initState();
  }

  checkUpdate()async{

    final playStoreId = 'com.coontent'; // If this value is null, its packagename will be considered
    final country = 'br'; // If this value is null 'us' will be the default value
    await AppVersionUpdate.checkForUpdates(
        playStoreId: playStoreId, country: country)
        .then((data) async {
      print(data.storeUrl);
      print(data.storeVersion);
      if(data.canUpdate!){
        AppVersionUpdate.showAlertUpdate(

            appVersionResult: data, context: context);
      }
    });
  }
}
