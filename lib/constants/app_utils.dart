// ignore_for_file: avoid_print

import 'dart:io';

import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

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

  static showInSnackBarNormal(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        closeIconColor: ColorClass.white,
        backgroundColor: ColorClass.greenDark,
        showCloseIcon: true,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(5),
        content: Text(
          message,
          style: TextStyleClass.poppinsRegular(
              fontSize: 15, color: ColorClass.white),
        )));
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
            color: isDisabled ? ColorClass.neutral200 : ColorClass.greenDark,
            boxShadow: [
              BoxShadow(
                  color: isDisabled
                      ? ColorClass.neutral200.withOpacity(0.08)
                      : ColorClass.greenDark.withOpacity(0.08),
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
                    style: TextStyleClass.poppinsMedium(
                            fontSize: 16, color: ColorClass.white)
                        .copyWith(height: 2.08),
                  )),
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
            style: TextStyleClass.poppinsRegular(
                fontSize: 15, color: ColorClass.greenDark),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Text(
            "No data found ",
            style: TextStyleClass.poppinsRegular(
                fontSize: 15, color: ColorClass.greenDark),
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
