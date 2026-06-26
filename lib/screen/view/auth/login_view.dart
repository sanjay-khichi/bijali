import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/colors.dart';
import '../../../utils/custom_button.dart';
import '../../controller/dashboard_controller.dart';

class LoginView extends StatelessWidget {
  LoginView({Key? key}) : super(key: key);

  DashBoardController dashBoardController = Get.put(DashBoardController());
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
    ],
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  "assets/images/login.png",
                ),
                fit: BoxFit.fill)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Obx(() => Theme(
                        data: ThemeData(
                          primarySwatch: Colors.blue,
                          unselectedWidgetColor: Colors.white, // Your color
                        ),
                        child: Checkbox(
                            key: key,
                            value: dashBoardController.getISChecked,
                            onChanged: (val) {
                              dashBoardController.setIsChecked = val!;
                            }),
                      )),
                  Expanded(
                    child: RichText(
                        text: TextSpan(children: [
                      TextSpan(
                          text: "I agree to",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                      TextSpan(
                        text: " terms and conditions",
                        style: TextStyle(fontSize: 16, color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async{

                            !await launchUrl(Uri.parse("https://hot-coontent.web.app/terms-coontent.html"));
                            print('Privacy Policy"');
                          },
                      ),
                      TextSpan(
                          text: " and",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                      TextSpan(
                          text: " privacy policy",
                          style: TextStyle(fontSize: 16, color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async{
                            !await launchUrl(Uri.parse("https://hot-coontent.web.app/privacy-policy.html"));
                           // https://hot-coontent.web.app/privacy-policy.html
                          },
                      ),
                    ])),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Obx(() => Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 50),
                  child: CustomButton(
                    borderColor: ColorConstants.appThemeColor,
                    isChild: true,
                    backgroundColor: dashBoardController.getISChecked == true
                        ? Colors.white
                        : Colors.grey,
                    borderRadius: 30,
                    margin: EdgeInsets.zero,
                    width: MediaQuery.of(context).size.width,
                    elevation: 0,
                    onPressed: () async {
                      if (dashBoardController.getISChecked == true) {
                        _googleSignIn.disconnect();
                        final GoogleSignInAccount? googleSignInAccount =
                            await _googleSignIn.signIn();
                        final GoogleSignInAuthentication
                            googleSignInAuthentication =
                            await googleSignInAccount!.authentication;
                        AuthCredential credential =
                            GoogleAuthProvider.credential(
                                accessToken:
                                    googleSignInAuthentication.accessToken,
                                idToken: googleSignInAuthentication.idToken);
                        final response = await FirebaseAuth.instance
                            .signInWithCredential(credential);
                        await dashBoardController.fetchMyDetails(
                            FirebaseAuth.instance.currentUser!.uid);
                        dashBoardController.fetchVideo();
                        if (response.additionalUserInfo!.isNewUser == true) {
                          dashBoardController.createAccount(response);
                        }
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/google.png",
                          height: 20,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        const Text(
                          "Login with Gmail     ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        )
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
