
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dart:io' show Platform;

import 'colors.dart';

showLoader(BuildContext? context) {
  Widget progressIndicator;
  if (kIsWeb) {
    progressIndicator = CircularProgressIndicator(
      valueColor:
          new AlwaysStoppedAnimation<Color>(ColorConstants.appThemeColor),
    );
  } else {
    progressIndicator = Platform.isAndroid
        ? CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(
                ColorConstants.appThemeColor),
          )
        : CupertinoActivityIndicator(
            radius: 14,
          );
  }

  return showDialog(
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.2),
    context: context!,
    builder: (_) => Center(child: progressIndicator),
  );
}

closeLoader(BuildContext? context) {
  Navigator.pop(context!);
}
