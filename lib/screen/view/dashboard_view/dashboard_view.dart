import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import '../../model/video_model.dart';
import '../native_ads_view/custom/config.dart';
import '../native_ads_view/custom/custom_options.dart';
import '../native_ads_view/custom/enums.dart';
import '../profile_view/profile_view.dart';
import 'commentView.dart';
import 'video_player_view.dart';

class DashBoardView extends StatefulWidget {
  const DashBoardView({Key? key}) : super(key: key);

  @override
  State<DashBoardView> createState() => _DashBoardViewState();
}

class _DashBoardViewState extends State<DashBoardView> {
  DashBoardController videoController = Get.put(DashBoardController());
  AdsController adsController = Get.put(AdsController());
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  CommentController commentController = Get.put(CommentController());
  PageController? _pageController;
  int _currentPageIndex = 0;

  // NativeAd? _nativeAd;
  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    print("===========referesh=====");
    videoController.fetchVideo();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    videoController.fetchVideo();
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }
  NativeAd? nativeAd;
  bool isScrollDown = true;
  @override
  void initState() {
    print("=================watch========");
    print(videoController.getInitialIndex);
   // _pageController?.addListener(_pageListener);
   // _pageController = new PageController()..addListener(_listener);
    _pageController = PageController(initialPage: videoController.getInitialIndex, viewportFraction: 1)..addListener(() {_listener(); });
    videoController.markAsWatched(
        FirebaseAuth.instance.currentUser!.uid,
        videoController.getController.first.id!);
    videoController.controller.first.isWatched = true;
    videoController.getController.first.isWatched = true;

    super.initState();
  }

  _listener() {
    setState(() {
      if (_pageController!.position.userScrollDirection == ScrollDirection.reverse) {
        isScrollDown =true;
        print('swiped to right');
      } else {
        isScrollDown =false;
        print('swiped to left');
      }
    });
  }
  loadAds() {
    videoController.setNativeAdIsLoaded = false;
    adsController.loadAds().then((value) {
      setState(() {
        nativeAd?.dispose();
        nativeAd = value;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    print("=========dispose========");
    _pageController!.removeListener(_pageListener);
    _pageController!.dispose();
    nativeAd?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {

    loadAds();
    super.didChangeDependencies();
  }

  void _pageListener() {
    setState(() {
      _currentPageIndex = _pageController!.page!.round();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Obx(() => SmartRefresher(
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: PageView.builder(
            physics: CustomPageViewScrollPhysics(),
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: videoController.getController!.length,
            onPageChanged: (index) {
              videoController.setInitialIndex = index;
              if (videoController.getController![index].isLoadAds != true &&
                  videoController.getController[index].isWatched == false) {

                videoController.markAsWatched(
                    FirebaseAuth.instance.currentUser!.uid,
                    videoController.getController[index].id!);
                videoController.controller[index].isWatched = true;
                videoController.getController[index].isWatched = true;
              }
              if (index != 0 && (index + 1) % 4 == 0) {
                print("loadAdd============");
                loadAds();
              }

              var watchCount = videoController.getController
                  .where((element) => element.isWatched == true)
                  .toList()
                  .length;
              var totalCount = videoController.getController.where((element) => element.isLoadAds != true).toList().length;
              var fetchNumber = (watchCount / totalCount) * 100;
              if (fetchNumber >= 50) {
                videoController.fetchVideo();
              } else if (index == videoController.getController.length - 1) {
                videoController.fetchVideo();
              }
            },
            itemBuilder: (context, i) {

              if (videoController.getController![i].isLoadAds == true) {
                if(isScrollDown ==false){
                  _pageController!.animateToPage(
                    i -1,
                    duration: Duration(microseconds: 5),
                    curve: Curves.ease,
                  );
                }
                if (nativeAd != null && videoController.getNativeAdIsLoaded == true) {
                  WidgetsBinding.instance!.addPostFrameCallback((_) {

                  });
                  return MainVideoViewer(nativeAd!);
                }
                else {
                  WidgetsBinding.instance!.addPostFrameCallback((_) {
                    setState(() {

                    });
                    if(isScrollDown==true){
                      Timer(Duration(seconds: 2), () {
                        print("============ScrollDirection");
                        print(isScrollDown);
                        print(_pageController!.position.userScrollDirection);
                        if (videoController.getNativeAdIsLoaded != true) {
                          //if( isScrollDown==true){
                          _pageController!.animateToPage(
                            i + 1,
                            duration: Duration(microseconds: 5),
                            curve: Curves.ease,
                          );
                        }
                        //}
                      });
                    }

                  });
                  return Center(child: CircularProgressIndicator());
                }
              }
              else {
                int index = i;
                videoController.setCurrentVideoIndex = i;
                return Column(
                  children: [
                    Expanded(
                        child: Stack(
                      children: [
                        VideoPlayers(
                            videoController.getController![index], index),
                        Positioned(
                          child: InkWell(
                            onTap: () {
                              if (videoController
                                      .getController![index].userId !=
                                  "00") {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProfileView(
                                        videoController
                                            .getController![index].userId!,
                                        false,
                                        url: videoController
                                            .getController![index].userProfile!,
                                        name: videoController
                                            .getController![index].userName!,
                                      ),
                                    ));
                              }
                            },
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
                          ),
                          bottom: MediaQuery.of(context).size.height / 25,
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
                          bottom: MediaQuery.of(context).size.height / 25,
                          right: 10,
                        ),
                      ],
                    )),
                  ],
                );
              }
            },
          ))),
    );

  }
}

class MainVideoViewer extends StatefulWidget {
  MainVideoViewer(this.nativeAd);
  NativeAd nativeAd;
  @override
  State<MainVideoViewer> createState() => _MainVideoViewerState();
}

class _MainVideoViewerState extends State<MainVideoViewer> {
  DashBoardController videoController = Get.find();
  CommentController commentController = Get.find();
  AdsController adsController = Get.find();
  NativeAd? nativeAd;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    nativeAd = widget.nativeAd;
    print("========AdWithView========");
    print(nativeAd?.responseInfo?.loadedAdapterResponseInfo?.adError?.message);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    print("+==========dispose========");
    nativeAd!.dispose();
    videoController.setNativeAdIsLoaded = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("========nativeAd.isBlank;====");
    print(nativeAd?.responseInfo!.responseExtras);
    if (videoController.getNativeAdIsLoaded != true && nativeAd == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return AdWidget(ad: nativeAd!);
    }
  }
}
