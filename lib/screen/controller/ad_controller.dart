
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../utils/wasabi_bucket.dart';
import '../view/native_ads_view/custom/config.dart';
import '../view/native_ads_view/custom/custom_options.dart';
import '../view/native_ads_view/custom/enums.dart';
import 'dashboard_controller.dart';

class AdsController extends GetxController{


  DashBoardController dashBoardController = Get.find();
  NativeAd? nativeAd;

   Future<NativeAd> loadAds()async{
   /*return  nativeAd = NativeAd(

       adUnitId: AddConfig.adKey,
       request: AdRequest(),
       listener: NativeAdListener(
         onAdLoaded: (Ad ad) {
           print('$NativeAd loaded.');
           dashBoardController.setNativeAdIsLoaded = true;
         },
         onAdFailedToLoad: (Ad ad, LoadAdError error) {
           print('$NativeAd failedToLoad: $error');
           dashBoardController.setNativeAdIsLoaded = false;
           ad.dispose();
         },
         onAdOpened: (Ad ad) => print('$NativeAd onAdOpened.'),
         onAdClosed: (Ad ad) => print('$NativeAd onAdClosed.'),
       ),
       nativeTemplateStyle: NativeTemplateStyle(

         templateType: TemplateType.medium,
         mainBackgroundColor: Colors.white12,
         callToActionTextStyle: NativeTemplateTextStyle(
           backgroundColor: Colors.black,
           size: 16.0,
         ),
         primaryTextStyle: NativeTemplateTextStyle(
           textColor: Colors.black38,
           backgroundColor: Colors.white70,
         ),
       ),
       nativeAdOptions: NativeAdOptions(mediaAspectRatio: MediaAspectRatio.portrait,videoOptions: VideoOptions(startMuted: false) ,shouldRequestMultipleImages: true)
     )..load();*/
   return nativeAd = await NativeAd(
      adUnitId: AddConfig.adKey,
      /// This does the job to show fullscreen ads
      customOptions: NativeAdCustomOptions.defaultConfig(NativeAdSize.fullScreen).toMap,
      nativeAdOptions: NativeAdOptions(

       // adChoicesPlacement: AdChoicesPlacement.bottomLeftCorner,
        mediaAspectRatio: MediaAspectRatio.any,
        videoOptions: VideoOptions(
          clickToExpandRequested: true,
          customControlsRequested: true,
          startMuted: false,
        ),
        //shouldRequestMultipleImages: true,
      ),
      request: const AdRequest(),
      /// This needs not to be changed
      factoryId: NativeAdConfig.adFactoryId,
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) async {
          print("===============native");
          print(ad.responseInfo.toString());
          print('$NativeAd loaded.');
            dashBoardController.setNativeAdIsLoaded = true;

        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('$NativeAd failedToLoad: $error');
          if (error.code == 3) {
            print('google out of ads for this config.');
          }
              dashBoardController.setNativeAdIsLoaded = false;
              ad.dispose();
        },
        onAdOpened: (Ad ad) => print('$NativeAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('$NativeAd onAdClosed.'),
      ),
    )..load();
  }
}