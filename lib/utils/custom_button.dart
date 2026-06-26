import 'package:flutter/material.dart';

import 'colors.dart';


class CustomButton extends StatelessWidget {
  final String buttonText;
  final Function onPressed;
  final double? width;
  final double height;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Color borderColor;
  final Color backgroundColor;
  final Color textColor;
  final double textSize;
  final double elevation;
  final double borderRadius;
  final bool isChild;
  final Widget child;

  CustomButton({
    this.buttonText = '',
    required this.onPressed,
    this.width,
    this.padding = const EdgeInsets.all(0),
    this.margin = const EdgeInsets.all(0),
    this.height = 60,
    this.borderColor = Colors.transparent,
    this.backgroundColor = ColorConstants.appThemeColor,
    this.textColor = Colors.white,
    this.textSize = 12,
    this.elevation = 0,
    this.borderRadius = 15,
    this.isChild = false,
    this.child = const SizedBox(),
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: MaterialButton(
        elevation: elevation,
        height: height,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(
            color: borderColor,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        minWidth: width ?? MediaQuery.of(context).size.width,
        padding: padding,
        color: backgroundColor,
        onPressed: () {
          onPressed();
        },
        child: isChild
            ? child
            : Text(
                buttonText,
                style: TextStyle(
                  fontSize: textSize,
                  color: textColor,
                ),
              ),
      ),
    );
  }
}
