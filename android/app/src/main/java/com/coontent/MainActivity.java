package com.coontent;



import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin;

public class MainActivity extends FlutterActivity {
    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        final GoogleMobileAdsPlugin.NativeAdFactory factory = new com.coontent.NativeAdFactoryImplementation(getLayoutInflater()); // reference to this package created factory
        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "google_native_mobile_ads_AdFactory", factory);
    }

    @Override
    public void cleanUpFlutterEngine(FlutterEngine flutterEngine) {
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "google_native_mobile_ads_AdFactory");
    }
}
