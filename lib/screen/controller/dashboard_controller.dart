import 'dart:async';
import 'dart:io';

import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:get/get.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:minio/io.dart';
import 'package:minio/minio.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:mongo_dart/mongo_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';

import '../../utils/loader.dart';
import '../../utils/wasabi_bucket.dart';
import '../model/video_model.dart';
import 'upload_video_controller.dart';
import 'dart:io' as fileInput;

class DashBoardController extends GetxController {
  var isLoading = true.obs;
  bool get getIsLoading => isLoading.value;
  set setIsLoading(bool val) {
    isLoading.value = val;
    isLoading.refresh();
  }

  var controller = <VideoModel>[].obs;
  List<VideoModel> get getController => controller.value;
  set setController(VideoModel val) {

    if(controller.value.where((element) => element.id ==val.id).isEmpty){
      if(getController.length!=0 &&getController.length %4 == 0){
        controller.value.add(VideoModel(isLoadAds: true));
        controller.value.add(val);
        controller.refresh();
      }else{
        controller.value.add(val);
        controller.refresh();
      }

    }

  }

  var dbConnection;
  fetchCoontent() async {
    fetchVideo();
    fetchMyDetails(FirebaseAuth.instance.currentUser!.uid);
  }

  final String collectionName = 'videos';
  final int batchSize = 10;
  final List<Map<String, dynamic>> videos = [];

  // int pageNumber = 1;
  int totalVideos = 0;
  StreamController<bool> _isLoadingController = StreamController<bool>.broadcast();
  Stream<bool> get isLoadingStream => _isLoadingController.stream;
  void setIsLoadingFirst(bool value) {
    _isLoadingController.add(value);
  }

  //late mongo.DbCollection collection;
  var lastObjectId = ObjectId();
  int pageNumber = 1; // Specify the page number
  int pageSize = 10;
  bool isLoadVideos = true;
  Future<void> fetchVideo() async {
    dbConnection = await fetchConnection();
    String userId = FirebaseAuth.instance.currentUser!.uid;
    print("========userId");
    print(userId);

    final final_pipeline1  =  [
      {
        '\$match': {
          "user_type": 1
        }
      },
      {
        '\$lookup': {
          'from': 'users',
          'localField': 'userId',
          'foreignField': 'userId',
          'as': 'owner',
        },
      },
      {
        '\$lookup': {
          'from': "watchedVideo",
          'localField': "video",
          'foreignField': "videoId",
          'as': "watchedVideo"
        }
      },
      {
        '\$match': {
          "watchedVideo.userId": { '\$ne': userId },
        }
      },
      { '\$sample': { 'size': 10 } },
      {
        '\$limit': 10,
      },

    ];


    try {

      if(isLoadVideos ==true){
        isLoadVideos = false;
        print("============before-Loading=======");
        var data = await dbConnection.collection("videos").modernAggregate(final_pipeline1).toList();
        print("============pipeline=======");
        print(data.toList().length);
        data.forEach((element) async {
          DefaultCacheManager().getSingleFile(url + element["thumbnail"], key: url + element["thumbnail"]);
          DefaultCacheManager().getSingleFile(url + element["video"], key: url + element["video"]);
          Owner owner = Owner();
          if(element["owner"].isNotEmpty){
            owner = Owner.fromJson(element["owner"].first);
          }else{
            owner = Owner(userName: "Anonymous",userEmail: "no email",userProfile: "",userId: "00");
          }
          if (!owner.userProfile!.contains("http")) {
            final thumbnail = url + owner.userProfile!;
            owner.userProfile = thumbnail;
          }
          final stream = url + element["video"];
          final thumbnail = url + element["thumbnail"];
          lastObjectId = element["_id"];
          pageNumber = pageNumber+1;
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
          setIsLoadingFirst(true);
          setIsLoading = false;
          isLoadVideos =true;
        });

      }


    } catch (e) {
      dbConnection = await fetchConnection();
      throw e;
    }
  }

  Stream<List<VideoModel>> getVideosStream() async*{
    // Establish MongoDB connection and execute the pipeline query
    dbConnection = await fetchConnection();
    String userId = FirebaseAuth.instance.currentUser!.uid;
    final final_pipeline1  =  [
      {
        '\$lookup': {
          'from': 'watchedVideo',
          'localField': 'video',
          'foreignField': 'videoId',
          'as': 'watchedVideo',
        },
      },
      {
        '\$lookup': {
          'from': 'users',
          'localField': 'userId',
          'foreignField': 'userId',
          'as': 'owner',
        },
      },
      {
        '\$match': {
          '\$or': [
            {
              'watchedVideo': {
                '\$not': {
                  '\$elemMatch': {
                    'userId': userId,
                  },
                },
              },
            },
          ],
          'user_type': 1,
        },
      },
      {
        '\$limit': 10,
      },
      {
        '\$facet': {
          'randomDocs': [
            {'\$sample': {'size': 10}},
            {'\$sort': {'create_date': -1}},
          ],
        },
      },
      {
        '\$unwind': {
          'path': '\$randomDocs',
          'includeArrayIndex': 'arrayIndex',
        },
      },
      {
        '\$replaceRoot': {
          'newRoot': '\$randomDocs',
        },
      }
    ];

    final streamController = StreamController<List<VideoModel>>();
    print("===========Before-Loaded========");
    dbConnection
        .collection("videos")
        .aggregateToStream(final_pipeline1)
        .listen((element) async{
          print("===========Loaded========");
      DefaultCacheManager().getSingleFile(url + element["video"], key: url + element["video"]);
      Owner owner = Owner.fromJson(element["owner"].first);
      if (!owner.userProfile!.contains("http")) {
        final thumbnail = url + owner.userProfile!;
        owner.userProfile = thumbnail;
      }
      final stream = url + element["video"];
      final thumbnail = url + element["thumbnail"];
      lastObjectId = element["_id"];
      pageNumber = pageNumber+1;
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
          isWatched: false);
      setIsLoadingFirst(true);
      setIsLoading = false;
      streamController.add(getController);
    }, onError: (error) {
      // Handle any errors that occur during the stream
      streamController.addError(error);
    });

    yield* streamController.stream;
  }



  Future<void> markAsWatched(String userId, String videoId) async {
    dbConnection = await fetchConnection();
    final watchedVideo = <String, dynamic>{
      'userId': userId,
      'videoId': videoId,
    };
    await dbConnection.collection('watchedVideo').insert(watchedVideo);
  }

  Future<bool> onLikeButtonTapped(bool isLiked) async {
    /// send your request here
    // final bool success= await sendRequest();

    /// if failed, you can do nothing
    // return success? !isLiked:isLiked;

    return !isLiked;
  }

  uploadContent(
      List<UploadContentPath> videoPathandThumbnailPath, BuildContext? context) async {
    try {

      dbConnection = await fetchConnection();
      Future.forEach(videoPathandThumbnailPath, (element) async {
        final video = await minio.fPutObject('coontent', element.name!, element.url!);
      }).then((value) async {
        await fileInput.File(videoPathandThumbnailPath.last.url!).delete();
        final uploadVideo = <String, dynamic>{
          'video': videoPathandThumbnailPath.first.name,
          'thumbnail': videoPathandThumbnailPath.last.name,
          "views": 0,
          "likes": 0,
          "userId": FirebaseAuth.instance.currentUser!.uid,
          "create_date": DateTime.now().toIso8601String(),
          "user_type": getMyAccountDetails.userType
        };
        await dbConnection.collection("videos").insert(uploadVideo);
        closeLoader(context);
        setCurrentIndex = 0;
      });
    } catch (e) {
      closeLoader(context);
      Toast.show("Something went wrong please try again");
      throw e;
    }
  }



  Future<void> createAccount(UserCredential userDetails) async {
    dbConnection = await fetchConnection();
    final userAccount = <String, dynamic>{
      'userId': userDetails.user!.uid,
      "user_email": userDetails.user!.email,
      "user_name": userDetails.user!.displayName,
      "user_profile": userDetails.user!.photoURL,
      "create_date": DateTime.now().toIso8601String(),
      "followers": 0,
      "following": 0,
      "is_active": true,
      "user_type": 0
    };
    await dbConnection.collection('users').insert(userAccount);
  }

  var currentIndex = 0.obs;
  int get getCurrentIndex => currentIndex.value;
  set setCurrentIndex(int val) {
    currentIndex.value = val;
    currentIndex.refresh();
  }

  var nativeAdIsLoaded = false.obs;
  bool get getNativeAdIsLoaded => nativeAdIsLoaded.value;
  set setNativeAdIsLoaded(bool val) {
    nativeAdIsLoaded.value = val;
    nativeAdIsLoaded.refresh();
  }

  var myAccountDetails = Owner().obs;
  Owner get getMyAccountDetails => myAccountDetails.value;
  set setMyAccountDetails(Owner val) {
    myAccountDetails.value = val;
    myAccountDetails.refresh();
  }

  fetchMyDetails(String uid) async {
    print("=================element=======");
    print(FirebaseAuth.instance.currentUser!.email);
    print(uid);
    dbConnection = await fetchConnection();
    final pipeline = [
      {
        '\$match': {
          'userId': uid,
        },
      },
    ];
     dbConnection
        .collection("users")
        .aggregateToStream(pipeline)
        .listen((element) async {
      print("=================Userelement=======");
      print(element);
      Owner mydetails = Owner.fromJson(element);
      if (!mydetails.userProfile!.contains("http")) {
        final thumbnail = url + mydetails.userProfile!;
        mydetails.userProfile = thumbnail;
        setMyAccountDetails = mydetails;
      } else {
        setMyAccountDetails = mydetails;
      }

      print("========after===mydetails=");
      print(mydetails.toJson());
    });
  }

  void updateName(String userId, String newName, BuildContext context) async {
    dbConnection = await fetchConnection();
    try {
      showLoader(context);
      final collection = dbConnection.collection('users');
      final query = where.eq('userId', userId);
      final update = modify.set('user_name', newName);
      collection.updateOne(query, update).then((WriteResult e) {
        closeLoader(context);
        print("====================update==========");
        print(e.serverResponses);
        fetchMyDetails(FirebaseAuth.instance.currentUser!.uid);
        Navigator.pop(context!);
      });
    } catch (e) {
      closeLoader(Get.context);
    }
  }

   saveVideo(VideoModel videoUrl, String userId,BuildContext context) async {
   // try{
     print(videoUrl.toJson());
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
        getController.forEach((element) {
          print(element.toJson());
        });
        getController.where((element) => element.id==videoUrl.id).forEach((element) {
          print(element.toJson());
        });
              getController.where((element) => element.id==videoUrl.id).first.isSaved =true;
              controller.value.where((element) => element.id==videoUrl.id).first.isSaved =true;
              controller.refresh();
        await dbConnection.close();
      }
      else{
        await collection.remove(where.eq('_id', existingVideo['_id']));
        closeLoader(context);
        getController.where((element) => element.url==videoUrl.url).first.isSaved =false;
        controller.value.where((element) => element.url==videoUrl.url).first.isSaved =false;
        controller.refresh();
      }
    /*}catch(e){
      closeLoader(context);
      throw e;
    }*/




  }

  var isChecked = false.obs;
  bool get getISChecked => isChecked.value;
  set setIsChecked(bool val){
    isChecked.value = val;
    isChecked.refresh();

  }



  void performBatchOperation() async {
    requestAllFilesAccessPermission();
    print("==============result=======");
    final dir = await getApplicationDocumentsDirectory();
    print(dir.path);
    final String maxBitrate = '1000000';

    final List<String> videoFiles1 = [];

    final String outputFolder = '/storage/emulated/0/Documents/coontent/encoded';
    Future.forEach(videoFiles1, (inputFile)async {
      print("=========ending==========");
      print(inputFile);
      final String escapedInputFile = '\"${fileInput.File(inputFile).path}\"';
      final String outputFileName = escapedInputFile.split('/').last; // Extract the filename
      final String outputFile = '\"$outputFolder/$outputFileName\"';
     // final String command = '-i $escapedInputFile ''-c:v libx264 -b:v $maxBitrate -maxrate $maxBitrate -bufsize $maxBitrate ''-c:a aac -b:a 128k ''-movflags faststart ''$outputFile';
      final String command = '-i $escapedInputFile -c:v libx264 -b:v $maxBitrate -maxrate $maxBitrate -bufsize $maxBitrate -vf scale=720:-2 -c:a aac -b:a 512k -movflags faststart $outputFile';

      await FFmpegKit.execute(command).then((session) async{
      await session.getLogs().then((value) {
        value.forEach((element) {
          print(element.getMessage());
        });
      });
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
         // print("=====success=====encoded=========video====");
         // print(Directory("/storage/emulated/0/Documents/coontent/encoded/$outputFileName").path.replaceAll('"', ''));

        // final file = fileInput.File(Directory("/storage/emulated/0/Documents/coontent/coontent/$outputFileName").path..replaceAll('"', ''));
         await fileInput.File(inputFile).delete();
        }
        else if (ReturnCode.isCancel(returnCode)) {
          // CANCEL
          print("=====not=====encoded=========video====");
        }
        else {
          // ERROR
          print("==========error===");
        }
      });

    });

  }

  Future<void> requestAllFilesAccessPermission() async {
    final PermissionStatus status = await Permission.manageExternalStorage.request();
    if (status.isGranted) {
      // Permission granted, you can access all files
    } else if (status.isDenied) {
      // Permission denied by the user, handle accordingly
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, show instructions or guide the user to settings
      openAppSettings();
    }
  }
  static var httpClient = new HttpClient();
   _downloadFile(String url, String filename) async {
     print(url);
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = '/storage/emulated/0/Documents/coontent';
    fileInput.File file =  fileInput.File('$dir/$filename');
    await file.writeAsBytes(bytes);
  }

  var _currentIndex = 0.obs;
   int get getCurrentVideoIndex => _currentIndex.value;
   set setCurrentVideoIndex(int val){
     _currentIndex.value =val;
     notifyChildrens();
   }

   var initialIndex =0.obs;
   int get getInitialIndex => initialIndex.value;
   set setInitialIndex(int val){
     initialIndex.value = val;
     initialIndex.refresh();
   }
}


class UploadContentPath{
  UploadContentPath(this.url,this.name);
  String? url;
  String? name;
}

