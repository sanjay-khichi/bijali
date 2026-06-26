import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';

import 'package:minio/io.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../utils/loader.dart';
import '../../utils/wasabi_bucket.dart';
import '../model/video_model.dart';
import 'dashboard_controller.dart';
class ProfileController extends GetxController{

  var dbConnection;


  int pageNumber = 1;
  var controller = <VideoModel>[].obs;
  List<VideoModel> get getController => controller.value;
  set setController(VideoModel val) {
    if(controller.value.where((element) => element.id ==val.id).isEmpty){
      if(getController.length!=0 &&getController.length %4 == 0){
        controller.value.add(VideoModel(isLoadAds: true,isWatched: false));
        controller.value.add(val);
        controller.refresh();
      }else{
        controller.value.add(val);
        controller.refresh();
      }
    }

  }
  var savedController = <VideoModel>[].obs;
  List<VideoModel> get getSavedController => savedController.value;
  set setSavedController(VideoModel val) {
    if(savedController.value.where((element) => element.id ==val.id).isEmpty){
      savedController.value.add(val);
      savedController.refresh();
    }

  }
  StreamController<bool> _isLoadingController = StreamController<bool>.broadcast();


  var isLoading = true.obs;
  bool get getIsLoading => isLoading.value;
  set setIsLoading(bool val) {
    isLoading.value = val;
    isLoading.refresh();
  }
  var loadingText = "Loading...".obs;
  String get getLoadingText => loadingText.value;
  set setLoadingText(String val){
    loadingText.value = val;
    loadingText.refresh();

  }
  var lastObjectId = ObjectId();
  Future<void> fetchVideo(String userId) async {
    print("============fetchMyVideos==========");
    dbConnection = await fetchConnection();
    controller.value.clear();
    controller.clear();
    final pipeline = [
      {
        '\$lookup': {
          'from': 'users',
          'localField': 'userId',
          'foreignField': 'userId',
          'as': 'owner'
        }
      },
      {
        '\$match': {
          'userId': userId,  // Filter videos by userId
        }
      },
      {'\$limit': 10},
      {'\$sort': {'_id': 1}},
    ];
    var data =   await dbConnection.collection("videos").modernAggregate(pipeline).toList();
    bool isEmpty = await data.isEmpty;
    print(data);
    var userData = await data;

 if(isEmpty){
   setLoadingText = "No data found";
 }else{
   await userData.forEach((element)async{
     DefaultCacheManager().getSingleFile(url + element["thumbnail"], key: url + element["thumbnail"]);
     DefaultCacheManager().getSingleFile(url + element["video"], key: url + element["video"]);

     Owner owner = Owner.fromJson(element["owner"].first);
     if(!owner.userProfile!.contains("http")){
       final thumbnail = url+owner.userProfile! ;
       owner.userProfile = thumbnail;
     }
     final stream = url+ element["video"];
     final thumbnail = url+ element["thumbnail"];
     lastObjectId = element["_id"];
     setController = VideoModel(
         id: element["video"],
         key: element["_id"].toString(),
         video: stream,
         url: stream,
         createDate: element["create_date"],
         likes: element["likes"],
         thumbnail: thumbnail,
         views: element["views"],
         userEmail: owner.userEmail,
         userName: owner.userName,
         userProfile: owner.userProfile,
         userId: owner.userId,
         isLiked: false,
         isWatched: false,
         isLoadAds: false

     );
     setIsLoading = false;
   });

 }

   if(await data ==0){
     setLoadingText = "No data found";
   }
  }
  Future<void> fetchNextVideo(String userId) async {
    dbConnection = await fetchConnection();

    final pipeline = [

      {
        '\$lookup': {
          'from': 'users',
          'localField': 'userId',
          'foreignField': 'userId',
          'as': 'owner'
        }
      },
      {
        '\$match': {
          '\$and': [
            {'_id': {'\$gt': lastObjectId}},
            { 'userId': userId, }
          ]
          // Filter videos by userId

        }
      },
      {'\$limit': 10},
      {'\$sort': {'_id': 1}},
    ];
    // Fetch the first 10 videos from the database.
    try{
      dbConnection.collection("videos").aggregateToStream(pipeline).forEach((element) async{
        await DefaultCacheManager().getSingleFile(url + element["video"], key: url + element["video"]);
        print(element);
        Owner owner = Owner.fromJson(element["owner"].first);
        if(!owner.userProfile!.contains("http")){

          final thumbnail = url+owner.userProfile! ;
          owner.userProfile = thumbnail;
        }
        final stream = url+element["video"];
        final thumbnail = url+element["thumbnail"];
        lastObjectId = element["_id"];
        setController = VideoModel(
            id: element["video"],
            key: element["_id"].toString(),
            video: stream,
            url: stream,
            createDate: element["create_date"],
            likes: element["likes"],
            thumbnail: thumbnail,
            views: element["views"],
            userEmail: owner.userEmail,
            userName: owner.userName,
            userProfile: owner.userProfile,
            userId: owner.userId,
            isLiked: false,
          isWatched: false
        );
        setIsLoading = false;
      });
      pageNumber = pageNumber + 1;
    }catch(e){

      throw e;
    }
  }


  var isSavedLoading = true.obs;
  bool get getIsSavedLoading => isLoading.value;
  set setIsSavedLoading(bool val) {
    isLoading.value = val;
    isLoading.refresh();
  }
  var savedloadingText = "Loading...".obs;
  String get getSavedLoadingText => loadingText.value;
  set setSavedLoadingText(String val){
    loadingText.value = val;
    loadingText.refresh();

  }
  var lastSavedObjectId = ObjectId();
  Future<void> fetchSavedVideo(String userId) async {
    dbConnection = await fetchConnection();
    savedController.value.clear();
    savedController.clear();
    final pipeline = [
      {
        '\$match': {
          'userId': userId,  // Filter videos by userId

        }
      },
      {'\$limit': 10}
    ];
    var data =   await dbConnection.collection("saved").aggregateToStream(pipeline);
    bool isEmpty = await data.isEmpty;

    if(isEmpty){
      setSavedLoadingText = "No data found";
    }else{
      await dbConnection.collection("saved").aggregateToStream(pipeline).forEach((element)async{
        await DefaultCacheManager().getSingleFile(element["videoId"], key: element["videoId"]);

        lastSavedObjectId = element["_id"];
        setSavedController = VideoModel(
            id: element["videoId"].toString().replaceAll(url, ""),
            key: element["_id"].toString(),
            video: element["videoId"],
            url: element["videoId"],
            createDate: element["createDate"],
            thumbnail: element["thumbnail"],
            userEmail: element["userEmail"],
            userName: element["userName"],
            userProfile: element["userProfile"],
            userId: element["userId"],
            isLiked: element["isLiked"],
            isWatched: false,
          isSaved: true

        );
        setIsSavedLoading = false;
        await DefaultCacheManager().getSingleFile(element["videoId"], key: element["videoId"]);
      });

    }

    if(await data ==0){
      setSavedLoadingText = "No data found";
    }
  }
  Future<void> fetchSavedNextVideo(String userId) async {
    dbConnection = await fetchConnection();

    final pipeline = [
      {'\$sort': {'_id': 1}},

      {
        '\$match': {
          '\$and': [
            {'_id': {'\$gt': lastSavedObjectId}},
            { 'userId': userId, }
          ]
          // Filter videos by userId

        }
      },
      {'\$limit': 10},

    ];
    // Fetch the first 10 videos from the database.
    try{
      dbConnection.collection("saved").aggregateToStream(pipeline).forEach((element) async{
        await DefaultCacheManager().getSingleFile(element["videoId"], key: element["videoId"]);
        lastSavedObjectId = element["_id"];
        setSavedController = VideoModel(
            id: element["videoId"].toString().replaceAll(url, ""),
            key: element["_id"].toString(),
            video: element["videoId"],
            url: element["videoId"],
            createDate: element["createDate"],
            thumbnail: element["thumbnail"],
            userEmail: element["userEmail"],
            userName: element["userName"],
            userProfile: element["userProfile"],
            userId: element["userId"],
            isLiked: element["isLiked"],
            isWatched: false,
            isSaved: true

        );

        setIsSavedLoading = false;
      });
      pageNumber = pageNumber + 1;
    }catch(e){

      throw e;
    }
  }



  Future<void> markAsWatched(String userId, String videoId) async {
    dbConnection = await fetchConnection();
    final watchedVideo = <String, dynamic>{
      'userId': userId,
      'videoId': videoId,
    };
    await dbConnection.collection('watchedVideo').insert(watchedVideo);
  }

  uploadContent(File profile, BuildContext? context) async {
    try {

      final video = await minio.fPutObject('coontent', "${FirebaseAuth.instance.currentUser!.uid}.jpg", profile.path);
      updateName(FirebaseAuth.instance.currentUser!.uid,"${FirebaseAuth.instance.currentUser!.uid}.jpg",context!);
    } catch (e) {
      throw e;
    }
  }

  void updateName(String userId, String profile,BuildContext context) async {
    print("====enter===");
    try{
      dbConnection = await fetchConnection();
      final collection = dbConnection.collection('users');
      final query = where.eq('userId', userId);
      final update = modify.set('user_profile', profile);
      collection.updateOne(query, update).then((WriteResult e)async{

        print("====================update==========");
        print(e.serverResponses);

        final thumbnail = await minio.presignedGetObject('coontent',profile );
        DashBoardController controller = Get.find();
        controller.myAccountDetails.value.userProfile = thumbnail;
        controller.myAccountDetails.refresh();

      });

    }catch(e){

    }


  }
  void updateUserDetails(String userId,BuildContext context, {String? name,email,phone}) async {
    print("====enter===");
    try{
      showLoader(context);
      dbConnection = await fetchConnection();
      final collection = dbConnection.collection('users');
      final query = where.eq('userId', userId);
      final update = ModifierBuilder().set('user_name', name).set('user_email', email).set('user_phone', phone);
      collection.updateOne(query, update).then((WriteResult e)async{

        DashBoardController controller = Get.find();
        controller.myAccountDetails.value.userName = name;
        controller.myAccountDetails.value.userPhone = phone;
        controller.myAccountDetails.value.userEmail = email;
        controller.myAccountDetails.refresh();
        closeLoader(context);
        Navigator.pop(context);



      });

    }catch(e){
      closeLoader(context);
    }


  }
  void diActivateAccount({String? userId,bool? isActive, BuildContext? context}) async {
    print("====enter===");
    try{
      showLoader(context);
      dbConnection = await fetchConnection();
      final collection = dbConnection.collection('users');
      final query = where.eq('userId', userId);
      final update = modify.set('is_active', isActive);
      collection.updateOne(query, update).then((WriteResult e)async{
        closeLoader(context);
        FirebaseAuth.instance.signOut();
        Navigator.of(context!).pop();
        Navigator.of(context).pop();
      });

    }catch(e){
      closeLoader(context);
    }


  }

  saveVideo(VideoModel videoUrl, String userId,BuildContext context) async {
    // try{
    showLoader(context);
    dbConnection = await fetchConnection();

    final collection = dbConnection.collection("saved");

    final existingVideo = await collection.findOne(where.eq('videoId', videoUrl.id).eq('userId', userId));
    if (existingVideo == null) {
      print("========null");
      final newVideo = <String, dynamic>{
        'userId': userId.toString(),
        'isSaved': videoUrl.isSaved,
        'videoId': videoUrl.url,
        'userEmail': videoUrl.userEmail,
        'userName': videoUrl.userName,
        'userProfile': videoUrl.userProfile,
        'thumbnail': videoUrl.thumbnail,
        'isLiked': videoUrl.isLiked,
        'video': videoUrl.video,
        "createDate": DateTime.now().toIso8601String(),

      };
      await collection.insert(newVideo);
      closeLoader(context);
      getController.where((element) => element.id==videoUrl.id).first.isSaved =true;
      controller.value.where((element) => element.id==videoUrl.id).first.isSaved =true;
      controller.refresh();
      await dbConnection.close();
    }
    else{
      await collection.remove(where.eq('_id', existingVideo['_id']));
      closeLoader(context);
      getController.where((element) => element.id==videoUrl.id).first.isSaved =false;
      controller.value.where((element) => element.id==videoUrl.id).first.isSaved =false;
      controller.refresh();
    }
    /*}catch(e){
      closeLoader(context);
      throw e;
    }*/




  }
  mySavedVideo(VideoModel videoUrl, String userId,BuildContext context) async {
    // try{
    showLoader(context);
    dbConnection = await fetchConnection();

    final collection = dbConnection.collection("saved");

    final existingVideo = await collection.findOne(where.eq('videoId', videoUrl.id).eq('userId', userId));
    if (existingVideo == null) {
      print("========null");
      final newVideo = <String, dynamic>{
        'userId': userId.toString(),
        'isSaved': videoUrl.isSaved,
        'videoId': videoUrl.url,
        'userEmail': videoUrl.userEmail,
        'userName': videoUrl.userName,
        'userProfile': videoUrl.userProfile,
        'thumbnail': videoUrl.thumbnail,
        'isLiked': videoUrl.isLiked,
        'video': videoUrl.video,
        "createDate": DateTime.now().toIso8601String(),

      };
      await collection.insert(newVideo);
      closeLoader(context);
      getSavedController.where((element) => element.id==videoUrl.id).first.isSaved =true;
      savedController.value.where((element) => element.id==videoUrl.id).first.isSaved =true;
      controller.refresh();
      await dbConnection.close();
    }
    else{
      await collection.remove(where.eq('_id', existingVideo['_id']));
      closeLoader(context);
      getSavedController.where((element) => element.id==videoUrl.id).first.isSaved =false;
      savedController.value.where((element) => element.id==videoUrl.id).first.isSaved =false;
      savedController.refresh();
    }
    /*}catch(e){
      closeLoader(context);
      throw e;
    }*/




  }

}