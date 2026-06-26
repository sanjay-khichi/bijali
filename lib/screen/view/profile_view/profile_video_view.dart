import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:toast/toast.dart';
import '../../../utils/colors.dart';
import '../../../utils/smooth_swipe.dart';
import '../../../utils/wasabi_bucket.dart';
import '../../controller/ad_controller.dart';
import '../../controller/comment_controller.dart';
import '../../controller/dashboard_controller.dart';
import '../../controller/profile_controller.dart';
import '../dashboard_view/commentView.dart';
import '../dashboard_view/dashboard_view.dart';
import '../dashboard_view/video_player_view.dart';
import '../native_ads_view/custom/config.dart';
import '../native_ads_view/custom/custom_options.dart';
import '../native_ads_view/custom/enums.dart';


class ProfileVideoView extends StatefulWidget {
  ProfileVideoView(this.uId,this.index,this.directJump,this.isSaved) ;
  String uId;
  int index;
  bool directJump=false;
  bool isSaved=false;
  @override
  State<ProfileVideoView> createState() => _ProfileVideoViewState();
}

class _ProfileVideoViewState extends State<ProfileVideoView> {
  ProfileController videoController = Get.put(ProfileController());
  DashBoardController dashBoardController = Get.find();
  AdsController adsController = Get.find();
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  NativeAd? _nativeAd;
  CommentController commentController = Get.put(CommentController());
  PageController _pageController = PageController();
  int _currentIndex = 0;
  bool isScrollDown = true;
  @override
  void initState() {
    // TODO: implement initState
    _pageController = PageController(initialPage: widget.index, viewportFraction: 1)..addListener(() {_listener(); });


    super.initState();
  }

  _listener() {
    setState(() {
      if (_pageController.position.userScrollDirection == ScrollDirection.reverse) {
        isScrollDown =true;
        print('swiped to right');
      } else {
        isScrollDown =false;
        print('swiped to left');
      }
    });
  }
  loadAds(){
    dashBoardController.nativeAdIsLoaded.value  = false;
    adsController.loadAds().then((value) {
      setState(() {
        _nativeAd?.dispose();
        _nativeAd = value;
      });

    });
  }
  @override
  void didChangeDependencies() {
    loadAds();

    super.didChangeDependencies();
  }


  @override
  void dispose() {
    // TODO: implement dispose
    _nativeAd?.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    ToastContext().init(context);
    return SafeArea(
      child: Scaffold(

        body: Obx((){
          if(widget.isSaved == true){
            return savedVideos();
          }
          else{
            return myVideos();
          }
        }
        ),
      ),
    );

  }


  myVideos(){

    return PageView.builder(
      physics: CustomPageViewScrollPhysics(),
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: videoController.getController!.length + (videoController.getController!.length ~/ 3),
      onPageChanged: (index){

        if (videoController.getController![index].isLoadAds != true &&
            videoController.getController[index].isWatched == false)
        {

          videoController.markAsWatched(
              FirebaseAuth.instance.currentUser!.uid,
              videoController.getController[index].id!);
          videoController.controller[index].isWatched = true;
          videoController.getController[index].isWatched = true;
        }


        if (index != 0 && (index + 1) % 4 == 0) {
          loadAds();
        }

        var watchCount = videoController.getController.where((element) => element.isWatched == true).toList().length;
        var totalCount = videoController.getController.where((element) => element.isLoadAds != true).toList().length;
        var fetchNumber = (watchCount / totalCount) * 100;
        if (fetchNumber >= 50) {
          videoController.fetchNextVideo(widget.uId);
        } else if (index == videoController.getController.length - 1) {
          videoController.fetchNextVideo(widget.uId);
        }

      },
      itemBuilder: (context, i) {
        if (videoController.getController![i].isLoadAds == true) {
          if(isScrollDown ==false){
            _pageController.animateToPage(
              i -1,
              duration: Duration(microseconds: 5),
              curve: Curves.ease,
            );
          }
          if (_nativeAd != null && dashBoardController.getNativeAdIsLoaded == true) {
            return MainVideoViewer(_nativeAd!);
          }
          else {
            WidgetsBinding.instance!.addPostFrameCallback((_) {
              print("=========NextIndex============");
              print(_currentIndex);
              print(i);
              Timer(Duration(seconds: 2), () {
                if (dashBoardController.getNativeAdIsLoaded != true) {
                  setState(() {

                  });
                  if(isScrollDown ==true){

                    _pageController.animateToPage(
                      i + 1,
                      duration: Duration(microseconds: 5),
                      curve: Curves.ease,
                    );


                  }
                  else{



                  }

                }
              });
            });
            return Center(child: CircularProgressIndicator());
          }
        }
        else {
          int index = i;
          _currentIndex = i;
          return Column(
            children: [
              Expanded(
                  child: Stack(
                    children: [
                      VideoPlayers(
                          videoController.getController![index], index),
                      Positioned(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CachedNetworkImage(
                              imageUrl: videoController
                                  .getController![index].userProfile!,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                    width: 50.0,
                                    height: 50.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                              placeholder: (context, url) => Container(
                                width: 50.0,
                                height: 50.0,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            if (videoController
                                .getController![index].userName ==
                                null ||
                                videoController
                                    .getController![index].userName ==
                                    "") ...[
                              Container(
                                height: 5,
                                width: 100,
                                color: Colors.grey.withOpacity(0.2),
                              )
                            ] else ...[
                              Text(
                                videoController
                                    .getController![index].userName!,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )
                            ]
                          ],
                        ),
                        bottom: MediaQuery.of(context).size.height / 20,
                        left: 30,
                      ),
                      Positioned(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {});
                                videoController.getController[index].isLiked =
                                !videoController
                                    .getController[index].isLiked!;
                              },
                              child: SvgPicture.asset(
                                "assets/icons/heart.svg",
                                color: videoController
                                    .getController[index].isLiked ==
                                    true
                                    ? Colors.red
                                    : Color(0xffFBFBFB),
                                height: 30,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            GestureDetector(
                              onTap: () {
                                commentController.fetchComments(
                                    videoController
                                        .getController![index].id!);
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CommentListScreen(
                                      videoId: videoController
                                          .getController![index].id!,
                                      userId: FirebaseAuth
                                          .instance.currentUser!.uid,
                                    );
                                  },
                                );
                              },
                              child: SvgPicture.asset(
                                "assets/icons/comment.svg",
                                height: 30,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            GestureDetector(
                              onTap: () {
                                videoController.saveVideo(
                                    videoController.getController![index],
                                    FirebaseAuth.instance.currentUser!.uid,
                                    context);
                              },
                              child: SvgPicture.asset(
                                videoController
                                    .getController![index].isSaved ==
                                    true
                                    ? "assets/icons/save_fill.svg"
                                    : "assets/icons/save.svg",
                                height: 20,
                                color: Color(0xffFBFBFB),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 0),
                              child: PopupMenuButton<int>(
                                iconSize: 20,
                                color: Color(0xffFBFBFB),
                                onSelected: (item) {},
                                itemBuilder: (context) => [
                                  PopupMenuItem<int>(
                                      value: 0, child: Text('Report')),
                                  PopupMenuItem<int>(
                                      value: 0,
                                      child: Text('Download'),
                                      onTap: () async {
                                        Toast.show(
                                          "Downloading....",
                                        );
                                        FileInfo? fileInfo =
                                        await DefaultCacheManager()
                                            .getFileFromCache(
                                            videoController
                                                .getController![index]
                                                .url!);
                                        Directory? directory = Directory(
                                            '/storage/emulated/0/Download');
                                        final downloadFilePath =
                                            '${directory.path}/${fileInfo?.file.path.split("/").last}';
                                        final downloadFile = await fileInfo
                                            ?.file
                                            .copy(downloadFilePath);
                                        print(downloadFile?.path);
                                        Toast.show(
                                          "Downloaded",
                                        );
                                        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
                                        // ignore: avoid_slow_async_io
                                        directory =
                                        await getExternalStorageDirectory();
                                      }),
                                ],
                              ),
                            ),
                          ],
                        ),
                        bottom: MediaQuery.of(context).size.height / 20,
                        right: 30,
                      ),
                    ],
                  )),
            ],
          );
        }
        if(widget.directJump==true){

          int index = i;
          if (index < videoController.getController!.length) {
            // Display content from the list
            return Column(
              children: [
                Expanded(
                    child: Stack(
                      children: [
                        VideoPlayers(
                            videoController.getController![index], index),
                        Positioned(
                          child: Row(

                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CachedNetworkImage(
                                imageUrl: videoController
                                    .getController![index].userProfile!,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                      width: 50.0,
                                      height: 50.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                placeholder: (context, url) =>
                                    Container(
                                      width: 50.0,
                                      height: 50.0,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.2),
                                        shape: BoxShape.circle,

                                      ),
                                    ),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              if(videoController.getController![index].userName==null||videoController.getController![index].userName=="")...[
                                Container(
                                  height: 5,
                                  width: 100,
                                  color: Colors.grey.withOpacity(0.2),
                                )
                              ]else...[
                                Text(
                                  videoController.getController![index].userName!,
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )
                              ]
                            ],
                          ),
                          bottom: MediaQuery.of(context).size.height / 20,
                          left: 30,
                        ),
                        Positioned(
                          child: Column(

                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: (){
                                  setState(() {

                                  });
                                  videoController
                                      .getController[index].isLiked =!videoController.getController[index].isLiked!;
                                },
                                child: SvgPicture.asset("assets/icons/heart.svg",color: videoController
                                    .getController[index].isLiked==true?Colors.red:Color(0xffFBFBFB),),
                              ),


                              SizedBox(
                                height: 20,
                              ),
                              GestureDetector(
                                onTap: (){
                                  commentController.fetchComments(
                                      videoController
                                          .getController![index].id!);
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CommentListScreen(
                                        videoId: videoController
                                            .getController![index].id!,
                                        userId: FirebaseAuth
                                            .instance.currentUser!.uid,
                                      );
                                    },
                                  );
                                },
                                child: SvgPicture.asset("assets/icons/comment.svg",),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              GestureDetector(
                                onTap: (){
                                  videoController.saveVideo(videoController.getController![index],FirebaseAuth.instance.currentUser!.uid,context);
                                },
                                child: SvgPicture.asset(videoController.getController![index].isSaved==true?"assets/icons/save_fill.svg":"assets/icons/save.svg",height: 30,color: Color(0xffFBFBFB),),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              PopupMenuButton<int>(
                                iconSize: 40,
                                color: Colors.white,
                                onSelected: (item) {},
                                itemBuilder: (context) => [
                                  PopupMenuItem<int>(
                                      value: 0, child: Text('Report')),
                                  PopupMenuItem<int>(
                                      value: 0,
                                      child: Text('Download'),
                                      onTap: () async {
                                        Toast.show(
                                          "Downloading....",
                                        );
                                        FileInfo? fileInfo =
                                        await DefaultCacheManager()
                                            .getFileFromCache(
                                            videoController
                                                .getController![index]
                                                .url!);
                                        Directory? directory = Directory(
                                            '/storage/emulated/0/Download');
                                        final downloadFilePath =
                                            '${directory.path}/${fileInfo?.file.path.split("/").last}';
                                        final downloadFile = await fileInfo
                                            ?.file
                                            .copy(downloadFilePath);
                                        print(downloadFile?.path);
                                        Toast.show(
                                          "Downloaded",
                                        );
                                        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
                                        // ignore: avoid_slow_async_io
                                        directory =
                                        await getExternalStorageDirectory();
                                      }),
                                ],
                              ),
                            ],
                          ),
                          bottom: MediaQuery.of(context).size.height / 20,
                          right: 30,
                        ),
                      ],
                    )),
                Obx(() {
                  if (videoController.getIsLoading == true) {
                    return SizedBox(
                        height: 4,
                        child: LinearProgressIndicator(
                          color: ColorConstants.appThemeColor,
                        ));
                  } else {
                    return SizedBox();
                  }
                })
              ],
            );
            index = i - (i ~/ 4);
          }
        }
        else{
          print("==dashBoardController.getNativeAdIsLoaded=");
          print(dashBoardController.getNativeAdIsLoaded);
          if (i > 0 && (i + 1) % 4 == 0 && dashBoardController.getNativeAdIsLoaded==true) {
            final adIndex = i ~/ 4;
            if (adIndex < videoController.getController!.length) {
              // Display ad widget
              return AdWidget(ad: _nativeAd!);
            }
          }
          else{
            print("====direct jump------");
            print(widget.directJump);
            print(i.toString());
            int index=i;
            if(dashBoardController.getNativeAdIsLoaded==true){
              index = i - (i ~/ 4);
            }


            if (index < videoController.getController!.length) {
              // Display content from the list
              return Column(
                children: [
                  Expanded(
                      child: Stack(
                        children: [
                          VideoPlayers(
                              videoController.getController![index], index),
                          Positioned(
                            child: Row(

                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: videoController
                                      .getController![index].userProfile!,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                        width: 50.0,
                                        height: 50.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                  placeholder: (context, url) =>
                                      Container(
                                        width: 50.0,
                                        height: 50.0,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.2),
                                          shape: BoxShape.circle,

                                        ),
                                      ),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                if(videoController.getController![index].userName==null||videoController.getController![index].userName=="")...[
                                  Container(
                                    height: 5,
                                    width: 100,
                                    color: Colors.grey.withOpacity(0.2),
                                  )
                                ]else...[
                                  Text(
                                    videoController.getController![index].userName!,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )
                                ]
                              ],
                            ),
                            bottom: MediaQuery.of(context).size.height / 20,
                            left: 30,
                          ),
                          Positioned(
                            child: Column(

                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: (){
                                    setState(() {

                                    });
                                    videoController
                                        .getController[index].isLiked =!videoController.getController[index].isLiked!;
                                  },
                                  child: SvgPicture.asset("assets/icons/heart.svg",color: videoController
                                      .getController[index].isLiked==true?Colors.red:Color(0xffFBFBFB),),
                                ),

                                SizedBox(
                                  height: 20,
                                ),
                                GestureDetector(
                                  onTap: (){
                                    commentController.fetchComments(
                                        videoController
                                            .getController![index].id!);
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CommentListScreen(
                                          videoId: videoController
                                              .getController![index].id!,
                                          userId: FirebaseAuth
                                              .instance.currentUser!.uid,
                                        );
                                      },
                                    );
                                  },
                                  child: SvgPicture.asset("assets/icons/comment.svg",),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                GestureDetector(
                                  onTap: (){
                                    videoController.saveVideo(videoController.getController![index],FirebaseAuth.instance.currentUser!.uid,context);
                                  },
                                  child: SvgPicture.asset(videoController.getController![index].isSaved==true?"assets/icons/save_fill.svg":"assets/icons/save.svg",height: 30,color: Color(0xffFBFBFB),),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                PopupMenuButton<int>(
                                  iconSize: 40,
                                  color: Colors.white,
                                  onSelected: (item) {},
                                  itemBuilder: (context) => [
                                    PopupMenuItem<int>(
                                        value: 0, child: Text('Report')),
                                    PopupMenuItem<int>(
                                        value: 0,
                                        child: Text('Download'),
                                        onTap: () async {
                                          Toast.show(
                                            "Downloading....",
                                          );
                                          FileInfo? fileInfo =
                                          await DefaultCacheManager()
                                              .getFileFromCache(
                                              videoController
                                                  .getController![index]
                                                  .url!);
                                          Directory? directory = Directory(
                                              '/storage/emulated/0/Download');
                                          final downloadFilePath =
                                              '${directory.path}/${fileInfo?.file.path.split("/").last}';
                                          final downloadFile = await fileInfo
                                              ?.file
                                              .copy(downloadFilePath);
                                          print(downloadFile?.path);
                                          Toast.show(
                                            "Downloaded",
                                          );
                                          // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
                                          // ignore: avoid_slow_async_io
                                          directory =
                                          await getExternalStorageDirectory();
                                        }),
                                  ],
                                ),
                              ],
                            ),
                            bottom: MediaQuery.of(context).size.height / 20,
                            right: 30,
                          ),
                        ],
                      )),
                  Obx(() {
                    if (videoController.getIsLoading == true) {
                      return SizedBox(
                          height: 4,
                          child: LinearProgressIndicator(
                            color: ColorConstants.appThemeColor,
                          ));
                    } else {
                      return SizedBox();
                    }
                  })
                ],
              );
            }
          }
        }

      },
    );
  }

  savedVideos(){
    return PageView.builder(
      physics: CustomPageViewScrollPhysics(),
      dragStartBehavior: DragStartBehavior.start,
      controller: PageController(initialPage: widget.index, viewportFraction: 1),
      scrollDirection: Axis.vertical,
      itemCount: videoController.getSavedController!.length + (videoController.getSavedController!.length ~/ 3),
      onPageChanged: (index){
        print(dashBoardController.getNativeAdIsLoaded);
        print("========dashBoardController.getNativeAdIsLoaded");
        if(dashBoardController.getNativeAdIsLoaded!=true){
          int i = index - (index / 4).floor();
          print("========No Add=====");
          print(videoController.getSavedController[i].isWatched);
          if(videoController.getSavedController[i].isWatched==false){
            videoController.savedController[i].isWatched=true;
            videoController.getSavedController[i].isWatched=true;
          }
        }else {
          if (index % 4 != 3  ){
            int i = index - (index / 4).floor();
            print("========mark as watched=====");
            print(videoController.getSavedController[i].isWatched);
            if(videoController.getSavedController[i].isWatched==false){

              videoController.savedController[i].isWatched=true;
              videoController.getSavedController[i].isWatched=true;
            }else{
              loadAds();
            }
          }
        }
        var watchCount =  videoController.getSavedController.where((element) => element.isWatched==true).toList().length;
        var totalCount = videoController.getSavedController.length;
        var fetchNumber = (watchCount/totalCount)*100;
        print(watchCount);
        print(totalCount);

        print((watchCount/totalCount)*100);
        if (fetchNumber==50 || (fetchNumber<51 &&fetchNumber>50)) {
          videoController.fetchSavedNextVideo(widget.uId);
        }else if (index == videoController.getSavedController.length-1){
          print("===========last=======");
          videoController.fetchSavedNextVideo(widget.uId);
        }

        setState(() {
          widget.directJump=false;

        });
      },
      itemBuilder: (context, i) {
        if(widget.directJump==true){

          int index = i;
          if (index < videoController.getSavedController!.length) {
            // Display content from the list
            return Column(
              children: [
                Expanded(
                    child: Stack(
                      children: [
                        VideoPlayers(
                            videoController.getSavedController![index], index),
                        Positioned(
                          child: Row(

                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CachedNetworkImage(
                                imageUrl: videoController
                                    .getSavedController![index].userProfile!,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                      width: 50.0,
                                      height: 50.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                placeholder: (context, url) =>
                                    Container(
                                      width: 50.0,
                                      height: 50.0,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.2),
                                        shape: BoxShape.circle,

                                      ),
                                    ),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              if(videoController.getSavedController![index].userName==null||videoController.getSavedController![index].userName=="")...[
                                Container(
                                  height: 5,
                                  width: 100,
                                  color: Colors.grey.withOpacity(0.2),
                                )
                              ]else...[
                                Text(
                                  videoController.getSavedController![index].userName!,
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )
                              ]
                            ],
                          ),
                          bottom: MediaQuery.of(context).size.height / 20,
                          left: 30,
                        ),
                        Positioned(
                          child: Column(

                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: (){
                                  setState(() {

                                  });
                                  videoController
                                      .getSavedController[index].isLiked =!videoController.getSavedController[index].isLiked!;
                                },
                                child: SvgPicture.asset("assets/icons/heart.svg",color: videoController
                                    .getSavedController[index].isLiked==true?Colors.red:Color(0xffFBFBFB),),
                              ),

                              SizedBox(
                                height: 20,
                              ),
                              GestureDetector(
                                onTap: (){
                                  commentController.fetchComments(
                                      videoController
                                          .getSavedController![index].id!);
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CommentListScreen(
                                        videoId: videoController
                                            .getSavedController![index].id!,
                                        userId: FirebaseAuth
                                            .instance.currentUser!.uid,
                                      );
                                    },
                                  );
                                },
                                child: SvgPicture.asset("assets/icons/comment.svg",),
                              ),
                              SizedBox(
                                height: 20,
                              ),

                              GestureDetector(
                                onTap: (){
                                  videoController.mySavedVideo(videoController.getSavedController![index],FirebaseAuth.instance.currentUser!.uid,context);
                                },
                                child: SvgPicture.asset(videoController.getSavedController![index].isSaved==true?"assets/icons/save_fill.svg":"assets/icons/save.svg",height: 30,color: Color(0xffFBFBFB),),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              PopupMenuButton<int>(
                                iconSize: 40,
                                color: Colors.white,
                                onSelected: (item) {},
                                itemBuilder: (context) => [
                                  PopupMenuItem<int>(
                                      value: 0, child: Text('Report')),
                                  PopupMenuItem<int>(
                                      value: 0,
                                      child: Text('Download'),
                                      onTap: () async {
                                        Toast.show(
                                          "Downloading....",
                                        );
                                        FileInfo? fileInfo =
                                        await DefaultCacheManager()
                                            .getFileFromCache(
                                            videoController
                                                .getSavedController![index]
                                                .url!);
                                        Directory? directory = Directory(
                                            '/storage/emulated/0/Download');
                                        final downloadFilePath =
                                            '${directory.path}/${fileInfo?.file.path.split("/").last}';
                                        final downloadFile = await fileInfo
                                            ?.file
                                            .copy(downloadFilePath);
                                        print(downloadFile?.path);
                                        Toast.show(
                                          "Downloaded",
                                        );
                                        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
                                        // ignore: avoid_slow_async_io
                                        directory =
                                        await getExternalStorageDirectory();
                                      }),
                                ],
                              ),
                            ],
                          ),
                          bottom: MediaQuery.of(context).size.height / 20,
                          right: 30,
                        ),
                      ],
                    )),
                Obx(() {
                  if (videoController.getIsSavedLoading == true) {
                    return SizedBox(
                        height: 4,
                        child: LinearProgressIndicator(
                          color: ColorConstants.appThemeColor,
                        ));
                  } else {
                    return SizedBox();
                  }
                })
              ],
            );
            index = i - (i ~/ 4);
          }
        }
        else{
          print("==dashBoardController.getNativeAdIsLoaded=");
          print(dashBoardController.getNativeAdIsLoaded);
          if (i > 0 && (i + 1) % 4 == 0 && dashBoardController.getNativeAdIsLoaded==true) {
            final adIndex = i ~/ 4;
            if (adIndex < videoController.getSavedController!.length) {
              // Display ad widget
              return MainVideoViewer( _nativeAd!);
            }
          }
          else{
            print("====direct jump------");
            print(widget.directJump);
            print(i.toString());
            int index=i;
            if(dashBoardController.getNativeAdIsLoaded==true){
              index = i - (i ~/ 4);
            }


            if (index < videoController.getSavedController!.length) {
              // Display content from the list
              return Column(
                children: [
                  Expanded(
                      child: Stack(
                        children: [
                          VideoPlayers(
                              videoController.getSavedController![index], index),
                          Positioned(
                            child: Row(

                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: videoController
                                      .getSavedController![index].userProfile!,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                        width: 50.0,
                                        height: 50.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                  placeholder: (context, url) =>
                                      Container(
                                        width: 50.0,
                                        height: 50.0,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.2),
                                          shape: BoxShape.circle,

                                        ),
                                      ),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                if(videoController.getSavedController![index].userName==null||videoController.getSavedController![index].userName=="")...[
                                  Container(
                                    height: 5,
                                    width: 100,
                                    color: Colors.grey.withOpacity(0.2),
                                  )
                                ]else...[
                                  Text(
                                    videoController.getSavedController![index].userName!,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )
                                ]
                              ],
                            ),
                            bottom: MediaQuery.of(context).size.height / 20,
                            left: 30,
                          ),
                          Positioned(
                            child: Column(

                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: (){
                                    setState(() {

                                    });
                                    videoController
                                        .getSavedController[index].isLiked =!videoController.getSavedController[index].isLiked!;
                                  },
                                  child: SvgPicture.asset("assets/icons/heart.svg",color: videoController
                                      .getSavedController[index].isLiked==true?Colors.red:Color(0xffFBFBFB),),
                                ),

                                SizedBox(
                                  height: 20,
                                ),
                                GestureDetector(
                                  onTap: (){
                                    commentController.fetchComments(
                                        videoController
                                            .getSavedController![index].id!);
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CommentListScreen(
                                          videoId: videoController
                                              .getSavedController![index].id!,
                                          userId: FirebaseAuth
                                              .instance.currentUser!.uid,
                                        );
                                      },
                                    );
                                  },
                                  child: SvgPicture.asset("assets/icons/comment.svg",),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                GestureDetector(
                                  onTap: (){
                                    videoController.mySavedVideo(videoController.getSavedController![index],FirebaseAuth.instance.currentUser!.uid,context);
                                  },
                                  child: SvgPicture.asset(videoController.getSavedController![index].isSaved==true?"assets/icons/save_fill.svg":"assets/icons/save.svg",height: 30,color: Color(0xffFBFBFB),),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: PopupMenuButton<int>(
                                    iconSize: 40,
                                    color: Colors.white,
                                    onSelected: (item) {},
                                    itemBuilder: (context) => [
                                      PopupMenuItem<int>(
                                          value: 0, child: Text('Report')),
                                      PopupMenuItem<int>(
                                          value: 0,
                                          child: Text('Download'),
                                          onTap: () async {
                                            Toast.show(
                                              "Downloading....",
                                            );
                                            FileInfo? fileInfo =
                                            await DefaultCacheManager()
                                                .getFileFromCache(
                                                videoController
                                                    .getSavedController![index]
                                                    .url!);
                                            Directory? directory = Directory(
                                                '/storage/emulated/0/Download');
                                            final downloadFilePath =
                                                '${directory.path}/${fileInfo?.file.path.split("/").last}';
                                            final downloadFile = await fileInfo
                                                ?.file
                                                .copy(downloadFilePath);
                                            print(downloadFile?.path);
                                            Toast.show(
                                              "Downloaded",
                                            );
                                            // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
                                            // ignore: avoid_slow_async_io
                                            directory =
                                            await getExternalStorageDirectory();
                                          }),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            bottom: MediaQuery.of(context).size.height / 20,
                            right: 30,
                          ),
                        ],
                      )),
                  Obx(() {
                    if (videoController.getIsSavedLoading == true) {
                      return SizedBox(
                          height: 4,
                          child: LinearProgressIndicator(
                            color:ColorConstants.appThemeColor,
                          ));
                    } else {
                      return SizedBox();
                    }
                  })
                ],
              );
            }
          }
        }

      },
    );
  }
}



