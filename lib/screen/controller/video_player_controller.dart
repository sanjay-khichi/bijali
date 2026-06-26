import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoController extends GetxController{

  VideoPlayerController? videoPlayerController  ;
  VideoPlayerController get getVideoPlayerController => videoPlayerController.obs.value!;
  set setVideoPlayerController(VideoPlayerController val){
    videoPlayerController.obs.value =val;
    videoPlayerController.obs.refresh();
  }

  var isLoading = false.obs;
  bool get getIsLoading => isLoading.value;
  set setIsLoading(bool val){
    isLoading.value = val;
    isLoading.refresh();
  }



}