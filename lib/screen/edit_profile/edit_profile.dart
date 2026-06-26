import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/colors.dart';
import '../controller/dashboard_controller.dart';
import '../controller/profile_controller.dart';

class ProfileEditPage extends StatefulWidget {
  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _globalKey1 = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  DashBoardController dashBoardController = Get.find();
  ProfileController videoController = Get.find();
  @override
  void initState() {
    // TODO: implement initState
    if(dashBoardController.getMyAccountDetails.userName!=null){
      nameController.text= dashBoardController.getMyAccountDetails.userName!;
    }
    if(dashBoardController.getMyAccountDetails.userEmail!=null){
      emailController.text= dashBoardController.getMyAccountDetails.userEmail!;
    }
    if(dashBoardController.getMyAccountDetails.userPhone!=null){
      numberController.text= dashBoardController.getMyAccountDetails.userPhone!;
    }


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Your Profile'),
      ),
      body: Form(
        key: _globalKey1,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Obx((){
                      if(dashBoardController.getMyAccountDetails.userProfile!=null){
                        return CircleAvatar(
                          radius: 64,
                            child: ClipOval(child: CachedNetworkImage(imageUrl: dashBoardController.getMyAccountDetails.userProfile!,height: 150,width: 150,fit: BoxFit.fill,)));
                      }else{
                        return CircleAvatar(
                          radius: 64,
                          backgroundImage: AssetImage('assets/images/profile.png'),
                        );
                      }

                    }),
                    Positioned(
                      bottom: -10,
                      right: 0,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                        ),
                        onPressed: () {
                          _showBottomSheet();
                        },
                        child: Icon(Icons.edit),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                validator: (value){
                  if(value!.isEmpty) {
                    return "Please enter  Name";
                  }return null;
                  },
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                validator: (value){
                  if(value!.isEmpty) {
                    return "Please enter  Email";
                  }return null;
                  },
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                keyboardType: TextInputType.number,
                maxLength: 10,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter Phone Number";
                  }
                  return null;
                },
                controller: numberController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  counterText: "",
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/images/india.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
                  prefixText: '+91 ',
                  prefixStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              Spacer(),

              ElevatedButton(

                onPressed: () {
                  if(_globalKey1.currentState!.validate()){
                    videoController.updateUserDetails(FirebaseAuth.instance.currentUser!.uid,context,email: emailController.text,name: nameController.text,phone:numberController.text );
                  } // Go back to the previous page
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _showBottomSheet() {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text("Gallery"),
                leading: const Icon(Icons.image),
                onTap: () async {
                  _getFromGallery();
                },
              ),
              ListTile(
                title: const Text("Camera"),
                leading: const Icon(Icons.camera),
                onTap: () async {
                  _getFromCamera();
                },
              )
            ],
          );
        });
  }

  /// Get from gallery
  _getFromGallery() async {
    Navigator.pop(context);
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile!.path,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: ColorConstants.appThemeColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );
    var data = await croppedFile?.readAsBytes();
    videoController.uploadContent(File(croppedFile!.path),context);


  }

  /// Get from Camera
  _getFromCamera() async {
    Navigator.pop(context);
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: ColorConstants.appThemeColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Cropper',
          ),
        ],
      );
      var data = await croppedFile?.readAsBytes();

      videoController.uploadContent(File(croppedFile!.path),context);

    }
  }
}