import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../utils/sound.dart';
import '../../../utils/wasabi_bucket.dart';
import '../../controller/dashboard_controller.dart';
import '../../controller/video_player_controller.dart';
import '../../model/video_model.dart';
class VideoPlayers extends StatefulWidget {
  VideoPlayers(this.video,this.index);
  VideoModel? video;
  int? index;

  @override
  State<VideoPlayers> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayers> {
  //double? setVolume ;
   VideoPlayerController? videoPlayerController;
  String? thumb;
  File? file;
  DashBoardController videoController = Get.put(DashBoardController());
  VideoController playerController = Get.put(VideoController());
   Color _widgetColor = Colors.white;
   bool isVisible =false;
   Future<void>? _initializeVideoPlayerFuture;
   bool showLocalThumbnail = false;
   FileInfo? thumbnailInfo;
  @override
  void initState() {
    // mail().then((value){
    playerController.isLoading.value = false;
    print(videoController.getController.length);
    print("============all===========");
    print("${url}test_video.h264");
    getFile();

    super.initState();
  }

  void changeColorAfterDelay() {
    _widgetColor = Colors.red;
  }

  getFile()async{
    FileInfo? fileInfo =   await DefaultCacheManager().getFileFromCache(widget.video!.video!);
    thumbnailInfo =   await DefaultCacheManager().getFileFromCache(widget.video!.thumbnail!);
    print(fileInfo.toString());
    double sound = await getSoundStatus;
    if(thumbnailInfo == null){
      setState(() {
        showLocalThumbnail = false;
      });
    }else{
      setState(() {
        showLocalThumbnail = true;
      });
    }
    if(fileInfo==null){
      print("===========isNulll===========");
      if(mounted){
        setState(() {

          videoPlayerController = VideoPlayerController.network(widget.video!.url!,httpHeaders: {'Range': 'bytes=0-'},);
          _initializeVideoPlayerFuture = videoPlayerController!.initialize();
          if(mounted){
            videoPlayerController!.seekTo(Duration.zero);
            videoPlayerController!.play();
            videoPlayerController!.setVolume( sound);
            videoPlayerController!.setLooping(true);
            playerController.setIsLoading = false;
            changeColorAfterDelay();
          }
        });
      }
    }
    else{
      print("===========isNotNulll===========");
      if(mounted){
        setState(() {
          // videoPlayerController?.pause();
          // videoPlayerController?.dispose();
          videoPlayerController = VideoPlayerController.file(fileInfo.file);
          _initializeVideoPlayerFuture = videoPlayerController!.initialize();
          if(mounted){
            videoPlayerController!.seekTo(Duration.zero);
            videoPlayerController!.play();
            videoPlayerController!.setVolume( sound);
            videoPlayerController!.setLooping(true);
            playerController.setIsLoading = false;
            changeColorAfterDelay();
          }
        });
      }

    }
  }

  double? sound;
  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.done){
          return Stack(
            children: [
              Container(
                color: _widgetColor,
                child: Opacity(
                  opacity: 0.8,
                  alwaysIncludeSemantics: true,
                  child: GestureDetector(
                    onDoubleTap: (){

                    },
                    onTap: () async{
                      sound = await getSoundStatus;
                      setState(() {
                        isVisible = true;
                        if ( sound == 0.0) {
                          print('============unmute========');
                          sound =  0;
                          setSoundStatus(Future.value(1.0));
                          videoPlayerController!.setVolume(1.0);
                        } else {
                          print('============mute========');

                          setSoundStatus(Future.value(0.0));
                          videoPlayerController!.setVolume(0.0);
                        }
                        Future.delayed(Duration(seconds: 1), () {

                          setState(() {
                            isVisible = false;
                          });

                        });

                      });
                    },
                    onLongPressEnd: (v) {
                      print(v.velocity);
                      print('=========end');
                      videoPlayerController!.play();
                    },
                    onLongPress: () {
                      print("==================on release==========");
                      videoPlayerController!.pause();
                    },
                    child: Stack(
                      children: [
                        VideoPlayer(videoPlayerController!),
                        Visibility(
                            visible: isVisible,
                            child: Center(child: CircleAvatar(child: Icon(sound !=0.0 ?Icons.volume_off:Icons.volume_up,size: 20,color: Colors.grey,)))),

                      ],
                    ),
                  ),
                ),
              ),

              if(videoPlayerController!.value.isPlaying==false && videoPlayerController?.value!.isBuffering==false)...[
                InkWell(
                  onTap: (){
                    setState(() {
                      videoPlayerController!.play();
                    });
                  },
                  child: Center(child: Icon(Icons.play_arrow_rounded,size: 200,color: Colors.white,)),
                )
              ]
            ],
          );
        }else{
          return Stack(
            children: [
              if(thumbnailInfo !=null)...[
                Image.file(thumbnailInfo!.file,fit: BoxFit.cover,height: MediaQuery.of(context).size.height,width: MediaQuery.of(context).size.width,),
              ]else...[
                CachedNetworkImage(
                  imageUrl: widget.video!.thumbnail!,
                  imageBuilder: (context, imageProvider) =>
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover),
                        ),
                      ),
                  placeholder: (context, url) =>
                      Container(
                        color: Colors.grey.withOpacity(0.5),
                      ),
                  errorWidget: (context, url, error) =>
                      Container(
                        color: Colors.grey.withOpacity(0.5),
                      ),
                ),
              ],
            Center(child: CircularProgressIndicator())
          ],);
        }
    },);
    return Obx((){
      if(playerController.getIsLoading==true){
        return Container(
          color: _widgetColor,
          child: Opacity(
            opacity: 0.8,
            alwaysIncludeSemantics: false,
            child: CachedNetworkImage(
              imageUrl: widget.video!.thumbnail!,
              imageBuilder: (context, imageProvider) =>
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover),
                    ),
                  ),
              placeholder: (context, url) =>
                  Container(
                    color: Colors.grey.withOpacity(0.5),
                  ),
              errorWidget: (context, url, error) =>
                  Container(
                    color: Colors.grey.withOpacity(0.5),
                  ),
            ),
          ),
        );
      }
      else{
        if(videoPlayerController !=null)
        return Stack(
          children: [
            Container(
              color: _widgetColor,
              child: Opacity(
                opacity: 0.8,
                alwaysIncludeSemantics: true,
                child: GestureDetector(
                  onDoubleTap: (){

                  },
                  onTap: () async{
                    sound = await getSoundStatus;
                    setState(() {
                      isVisible = true;
                      if ( sound == 0.0) {
                        print('============unmute========');
                        sound =  0;
                        setSoundStatus(Future.value(1.0));
                        videoPlayerController!.setVolume(1.0);
                      } else {
                        print('============mute========');

                        setSoundStatus(Future.value(0.0));
                        videoPlayerController!.setVolume(0.0);
                      }
                      Future.delayed(Duration(seconds: 1), () {

                        setState(() {
                          isVisible = false;
                        });

                      });

                    });
                  },
                  onLongPressEnd: (v) {
                    print(v.velocity);
                    print('=========end');
                    videoPlayerController!.play();
                  },
                  onLongPress: () {
                    print("==================on release==========");
                    videoPlayerController!.pause();
                  },
                  child: Stack(
                    children: [
                      VideoPlayer(videoPlayerController!),
                      Visibility(
                          visible: isVisible,
                          child: Center(child: CircleAvatar(child: Icon(sound !=0.0 ?Icons.volume_off:Icons.volume_up,size: 20,color: Colors.grey,)))),

                    ],
                  ),
                ),
              ),
            ),

            if(videoPlayerController!.value.isPlaying==false && videoPlayerController?.value!.isBuffering==false)...[
              InkWell(
                onTap: (){
                  setState(() {
                    videoPlayerController!.play();
                  });
                },
                child: Center(child: Icon(Icons.play_arrow_rounded,size: 200,color: Colors.white,)),
              )
            ]
          ],
        );
        else{
          return Container(
            color: Colors.grey.shade50,
          );
        }
      }
    });




  }

  @override
  void dispose() {
    // TODO: implement dispose
    if(videoPlayerController !=null)
    videoPlayerController!.dispose();
    super.dispose();
  }
}