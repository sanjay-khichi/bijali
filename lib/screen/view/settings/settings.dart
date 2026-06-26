import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:rate_my_app/rate_my_app.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controller/profile_controller.dart';
import '../../edit_profile/edit_profile.dart';
import '../about_us_view/about_us_view.dart';


class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool notificationEnabled = true;
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  late NotificationSettings settings ;
  ProfileController profileController = Get.find();
  static Widget buildProgressIndicator(BuildContext context) => SizedBox();
  WidgetBuilder builder = buildProgressIndicator;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: ListView(
        children: [
          ListTile(
            leading:  Image.asset('assets/images/profile.png',
            width: 28,
            height: 28,),
            title: Text('Edit Your Profile'),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> ProfileEditPage()));
            },
          ),

         /* SwitchListTile(
            title: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('Notification'),
            ),
            subtitle: Text("If you disable notifications,you won't get latest updates from your followers"),
            value: settings.authorizationStatus == AuthorizationStatus.authorized,
            onChanged: (value) {
              setState(() {
                notificationEnabled = value;
                notificationPermissions();
              });
            },
            secondary: Image.asset('assets/images/notification.png',
              width: 28,
              height: 28,),
          ),*/
          Divider(),
          RateMyAppBuilder(
            builder: builder,
            onInitialized: (context, rateMyApp) {
              setState(() => builder = (context) => ListTile(
                leading: Image.asset('assets/images/rating.png',
                  width: 30,
                  height: 30,),
                title: Text('Rate Bijali'),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () async{
                 // Navigator.push(context, MaterialPageRoute(builder: (context) => _RateMyAppTestApp(),));
                  await rateMyApp.showRateDialog(context); // We launch the default Rate my app dialog.

                },
              ));
              rateMyApp.conditions.forEach((condition) {
                if (condition is DebuggableCondition) {
                  print(condition.valuesAsString); // We iterate through our list of conditions and we print all debuggable ones.
                }
              });

              print('Are all conditions met ? ' + (rateMyApp.shouldOpenDialog ? 'Yes' : 'No'));

              if (rateMyApp.shouldOpenDialog) {
                rateMyApp.showRateDialog(context);
              }
            },
          ),

          Divider(),
          ListTile(
            leading: Image.asset('assets/images/share.png',
              width: 26,
              height: 26,),
            title: Text('Share Bijali'),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Share.share('📢 Exciting News! 🎉📲\n\n'
                  'Introducing Bijali - the ultimate short video app that will keep you entertained for hours! 🌟🎥\n\n'
                  '📲 Download now and experience the magic of Bijali on your device: https://play.google.com/store/apps/details?id=com.coontent\n\n'
                  '🌟 Features that make Bijali stand out:\n'
                  '✨ Create and share captivating 15 to 60-second videos.\n'
                  '✨ Explore an endless variety of content, from dance routines to comedy skits and DIY tutorials.\n'
                  '✨ Unleash your creativity with our advanced editing tools and effects.\n'
                  '✨ Connect with a vibrant community of like-minded individuals.\n'
                  '✨ Discover trending videos and personalized recommendations.\n'
                  '✨ Share your videos effortlessly with friends, family, and followers on social media platforms.\n'
                  '✨ Let your talent shine and become the next viral sensation!\n\n'
                  '👉 Don\'t miss out on the opportunity to join the Bijali community. Click here to download now: https://play.google.com/store/apps/details?id=com.coontent\n\n'
                  '🌟 Join us on this incredible journey of creativity, inspiration, and entertainment. Download Bijali today and let your talent take center stage! 🌟🎉',);
            },
          ),
          Divider(),
          ListTile(
            leading: Image.asset('assets/images/info.png',
              width: 28,
              height: 28,),
            title: Text('About Us'),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context)=> AboutUsPage()));},
          ),
          Divider(),
          ListTile(
            leading: Image.asset('assets/images/privacy_policy.png',
              width: 28,
              height: 28,),
            title: Text('Privacy Policy'),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
             launchUrl(Uri.parse("https://hot-coontent.web.app/privacy-policy.html"));
            },
          ),
          Divider(),
          ListTile(
            leading: Image.asset('assets/images/terms_and_condition.png',
              width: 28,
              height: 28,),
            title: Text('Terms and Conditions'),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () async{
              !await launchUrl(Uri.parse("https://hot-coontent.web.app/terms-coontent.html"));
              },
          ),
          Divider(),
          ListTile(
            leading: Image.asset('assets/images/user.png', width: 28, height: 28,),
            title: Text('Deactivate Account'),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              _showDeactivateConfirmationDialog();
            },
          ),
          Divider(),
          ListTile(
            leading: Image.asset('assets/images/logout.png', width: 28, height: 28,),
            title: Text('Logout'),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: (


                ) {_showLogoutConfirmationDialog();},
          ),
          Divider(),
        ],
      ),
    );
  }
  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log out'),
          content: Text('Are you sure you want to log out from current account ?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () {

                FirebaseAuth.instance.signOut();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void _showDeactivateConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Deactivate Account'),
          content: Text('Are you sure you want to Deactivate your account ?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                profileController.diActivateAccount(userId: FirebaseAuth.instance.currentUser!.uid,context: context,isActive: false);
              },
            ),
          ],
        );
      },
    );
  }
}

class _RateMyAppTestApp extends StatefulWidget {
  /// Creates a new Rate my app test app instance.
  const _RateMyAppTestApp();

  @override
  State<StatefulWidget> createState() => _RateMyAppTestAppState();
}

/// The body state of the main Rate my app test widget.
class _RateMyAppTestAppState extends State<_RateMyAppTestApp> {
  /// The widget builder.
  WidgetBuilder builder = buildProgressIndicator;

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: const Text('Rate my app !'),
      ),
      body: RateMyAppBuilder(
        rateMyApp: RateMyApp(googlePlayIdentifier: "com.talentESO"),
        builder: builder,
        onInitialized: (context, rateMyApp) {

          setState(() => builder = (context) => ContentWidget(rateMyApp: rateMyApp));
          rateMyApp.conditions.forEach((condition) {
            if (condition is DebuggableCondition) {
              print(condition.valuesAsString); // We iterate through our list of conditions and we print all debuggable ones.
            }
          });

          print('Are all conditions met ? ' + (rateMyApp.shouldOpenDialog ? 'Yes' : 'No'));

          if (rateMyApp.shouldOpenDialog) {
            rateMyApp.showRateDialog(context);
          }
        },
      ),
    ),
  );

  /// Builds the progress indicator, allowing to wait for Rate my app to initialize.
  static Widget buildProgressIndicator(BuildContext context) => const Center(child: CircularProgressIndicator());
}


/// The app's main content widget.
class ContentWidget extends StatefulWidget {
  /// The Rate my app instance.
  final RateMyApp rateMyApp;

  /// Creates a new content widget instance.
  const ContentWidget({
    required this.rateMyApp,
  });

  @override
  State<StatefulWidget> createState() => _ContentWidgetState();
}

/// The content widget state.
class _ContentWidgetState extends State<ContentWidget> {
  /// Contains all debuggable conditions.
  List<DebuggableCondition> debuggableConditions = [];

  /// Whether the dialog should be opened.
  bool shouldOpenDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => refresh());
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 40),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (DebuggableCondition condition in debuggableConditions) //
          textCenter(condition.valuesAsString),
        textCenter('Are conditions met ? ' + (shouldOpenDialog ? 'Yes' : 'No')),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: ElevatedButton(
            onPressed: () async {
              await widget.rateMyApp.showRateDialog(context); // We launch the default Rate my app dialog.
              refresh();
            },
            child: const Text('Launch "Rate my app" dialog'),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            await widget.rateMyApp.showStarRateDialog(context, actionsBuilder: (_, stars) => starRateDialogActionsBuilder(context, stars)); // We launch the Rate my app dialog with stars.
            refresh();
          },
          child: const Text('Launch "Rate my app" star dialog'),
        ),
        ElevatedButton(
          onPressed: () async {
            await widget.rateMyApp.reset(); // We reset all Rate my app conditions values.
            refresh();
          },
          child: const Text('Reset'),
        ),
      ],
    ),
  );

  /// Returns a centered text.
  Text textCenter(String content) => Text(
    content,
    textAlign: TextAlign.center,
  );

  /// Allows to refresh the widget state.
  void refresh() {
    setState(() {
      debuggableConditions = widget.rateMyApp.conditions.whereType<DebuggableCondition>().toList();
      shouldOpenDialog = widget.rateMyApp.shouldOpenDialog;
    });
  }

  List<Widget> starRateDialogActionsBuilder(BuildContext context, double? stars) {
    final Widget cancelButton = RateMyAppNoButton(
      // We create a custom "Cancel" button using the RateMyAppNoButton class.
      widget.rateMyApp,
      text: MaterialLocalizations.of(context).cancelButtonLabel.toUpperCase(),
      callback: refresh,
    );
    if (stars == null || stars == 0) {
      // If there is no rating (or a 0 star rating), we only have to return our cancel button.
      return [cancelButton];
    }

    // Otherwise we can do some little more things...
    String message = 'You put ' + stars.round().toString() + ' star(s). ';
    Color color = Colors.black;
    switch (stars.round()) {
      case 1:
        message += 'Did this app hurt you physically ?';
        color = Colors.red;
        break;
      case 2:
        message += 'That\'s not really cool man.';
        color = Colors.orange;
        break;
      case 3:
        message += 'Well, it\'s average.';
        color = Colors.yellow;
        break;
      case 4:
        message += 'This is cool, like this app.';
        color = Colors.lime;
        break;
      case 5:
        message += 'Great ! <3';
        color = Colors.green;
        break;
    }

    return [
      TextButton(
        onPressed: () async {
          print(message);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: color,
            ),
          );

          // This allow to mimic a click on the default "Rate" button and thus update the conditions based on it ("Do not open again" condition for example) :
          await widget.rateMyApp.callEvent(RateMyAppEventType.rateButtonPressed);
          Navigator.pop<RateMyAppDialogButton>(context, RateMyAppDialogButton.rate);
          refresh();
        },
        child: Text(MaterialLocalizations.of(context).okButtonLabel.toUpperCase()),
      ),
      cancelButton,
    ];
  }
}