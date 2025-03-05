// ignore_for_file: avoid_print

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:canteen_app/constants/color_class.dart';
import 'package:canteen_app/constants/textstyle_class.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

// import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter/material.dart';


class AppUtils {
  ///To check internet connection
  static Future<bool> hasInternet() async {
    if (kIsWeb) {
      // For web, we'll return true since the browser handles connectivity
      return true; // Web browsers handle offline state automatically
    } else {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          return true;
        }
      } on SocketException catch (_) {
        return false;
      }
      return false;
    }
  }

  /// Navigate to a new screen/widget
  static navigateTo(BuildContext context, Widget widget) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
  }

  /// Show a normal snackbar with a message
  static showInSnackBarNormal(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        closeIconColor: ColorClass.white,
        backgroundColor: ColorClass.primaryBase,
        showCloseIcon: true,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(5),
        content: Text(
          message,
          style: TextStyleClass.primaryFont400(15, ColorClass.white),
        )));
  }
static showLoaderDialog(BuildContext context) {
 showDialog(
   barrierDismissible: false,
   context: context,
   builder: (BuildContext context) {
     return Center(
       child: Container(
         width: 80,
         height: 80,
         decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(12),
         ),
         child: const Center(
           child: CupertinoActivityIndicator(
             color: ColorClass.primaryBase,
             radius: 16,
           ),
         ),
       ),
     );
   }
 );
}
  static forwardButton(
    BuildContext context,
    Function() onTap,
    String title,
    Color color,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: MediaQuery.of(context).size.width / 2,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: color,
        ),
        child: Center(
          child: Text(title,
              style: TextStyleClass.primaryFont500(12, ColorClass.white)),
        ),
      ),
    );
  }

  

  static buttonWithIconText({
    required void Function() onTap,
    required double hight,
    required double width,
    required String title,
    required IconData icon,
    required Color color,
    required Color borderColor,
    required double borderRadius,
    double borderWidth = 1,
    required TextStyle textStyle,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: hight,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor, width: borderWidth),
          color: color,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(
              width: 8,
            ),
            Text(title, style: textStyle),
          ],
        ),
      ),
    );
  }

 

  static buttonWithOnlyText({
    required void Function() onTap,
    required double horizontalPadding,
    required double verticalPadding,
    required String title,
    required Color color,
    required Color borderColor,
    required double borderRadius,
    double borderWidth = 1,
    required TextStyle textStyle,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding, vertical: verticalPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor, width: borderWidth),
          color: color,
        ),
        child: Text(title, style: textStyle),
      ),
    );
  }

  static agreeButton({
    required void Function() onTap,
    required String title,
    required double width,
    bool isDisabled = false,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isDisabled
          ? () {
              print('disabled');
            }
          : onTap,
      child: Container(
        width: width,
        height: 52,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isDisabled ? ColorClass.neutral200 : ColorClass.primaryBase,
            boxShadow: [
              BoxShadow(
                  color: isDisabled
                      ? ColorClass.neutral200.withOpacity(0.08)
                      : ColorClass.primaryBase.withOpacity(0.08),
                  blurRadius: 2,
                  spreadRadius: 0,
                  offset: const Offset(0, 1))
            ]),
        child: Center(
            child: isLoading
                ? const CupertinoActivityIndicator(
                    color: Colors.white,
                  )
                : Text(
                    title,
                    style:
                        TextStyleClass.primaryFont500(16, ColorClass.textWhite0)
                            .copyWith(height: 2.08),
                  )),
      ),
    );
  }

 

  

  static rectangularContainerWithStroke({
    required Color strokeColor,
    required void Function() onTap,
    required double strokeThickness,
    required double imageHeight,
    required double imageWidth,
    required String avatarImage,
  }) {
    return GestureDetector(
      onTap:
          onTap, // Wrap the container in a GestureDetector for tap functionality
      child: Container(
        padding: EdgeInsets.all(strokeThickness),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26), color: strokeColor),
        child: Center(
          child: SizedBox(
            width: imageWidth,
            height: imageWidth,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
              child: Image.asset(
                avatarImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static noDataFoundWidget() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SvgPicture.asset(
          //   ImageClass
          //       .no_data_image, height: 80.0,),
          const SizedBox(
            height: 10.0,
          ),
          Text(
            "Oops!!",
            style: TextStyleClass.primaryFont300(15, ColorClass.primaryBase),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Text(
            "No data found ",
            style: TextStyleClass.primaryFont300(15, ColorClass.primaryBase),
          ),
        ],
      ),
    );
  }

  static loadingWidget(BuildContext context, double? size) {
    return SizedBox(
        height: size,
        child: const Center(
            child: CupertinoActivityIndicator(
          radius: 10.0,
        )));
  }

  static String formatTime(DateTime? dateTime) {
    // Format the DateTime to "hh:mm a" using intl package
    String formattedDate =
        DateFormat("hh:mm a").format(dateTime ?? DateTime.now());
    return formattedDate;
  }

 static String formatDateForApi(String dateStr) {
  try {
    // Split the date string
    final parts = dateStr.split('-');
    if (parts.length == 3) {
      final day = parts[0];
      final month = parts[1];
      final year = parts[2];
      return '$year-$month-$day'; // Convert to ISO format
    }
    return dateStr;
  } catch (e) {
    return dateStr;
  }
}


  static loadingWidgetWhite(BuildContext context, double? size) {
    return SizedBox(
        height: size,
        child: const Center(
            child: CupertinoActivityIndicator(
          radius: 10.0,
          color: Colors.white,
        )));
  }
}
