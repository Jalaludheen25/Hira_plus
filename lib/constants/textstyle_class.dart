import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const String primaryFontName = 'Inter';

class TextStyleClass {
  static const double textHeight = 1;

  static TextStyle primaryFont300(double size, Color color) => TextStyle(
      fontFamily: primaryFontName,
      fontWeight: FontWeight.w300,
      color: color,
      height: textHeight,
      fontSize: size,
      decoration: TextDecoration.none);

  static TextStyle primaryFont400(double size, Color color) => TextStyle(
      fontFamily: primaryFontName,
      fontWeight: FontWeight.w400,
      color: color,
      height: textHeight,
      fontSize: size,
      decoration: TextDecoration.none);

  static TextStyle primaryFont500(double size, Color color) => TextStyle(
      fontFamily: primaryFontName,
      fontWeight: FontWeight.w500,
      color: color,
      height: textHeight,
      fontSize: size,
      decoration: TextDecoration.none);

  static TextStyle primaryFont600(double size, Color color) => TextStyle(
      fontFamily: primaryFontName,
      fontWeight: FontWeight.w600,
      color: color,
      height: textHeight,
      fontSize: size,
      decoration: TextDecoration.none);

  static TextStyle primaryFont700(double size, Color color) => TextStyle(
      fontFamily: primaryFontName,
      fontWeight: FontWeight.w700,
      color: color,
      height: textHeight,
      fontSize: size,
      decoration: TextDecoration.none);

  static TextStyle poppinsRegular({required double fontSize, Color? color}) =>
      GoogleFonts.poppins(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.normal,
      );

  static TextStyle poppinsMedium({required double fontSize, Color? color}) =>
      GoogleFonts.poppins(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
      );
  static TextStyle poppinsBold({required double fontSize, Color? color}) =>
      GoogleFonts.poppins(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      );

  static TextStyle poppinsSemiBold({required double fontSize, Color? color}) =>
      GoogleFonts.poppins(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
      );

  static TextStyle popinsDefault({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    TextDecoration? decoration,
    FontStyle? fontStyle,
  }) =>
      GoogleFonts.poppins(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        decoration: decoration,
        fontStyle: fontStyle,
      );
}
