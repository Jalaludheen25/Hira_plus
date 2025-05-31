import 'package:flutter/material.dart';

class ColorClass {
  static const Color backgroundColor = Color(0xffFFFFFF);
  static const Color white = Color(0xffFFFFFF);
  static const Color black = Color(0xff000000);
  static const Color transparent = Colors.transparent;
  // Neutral Color Palette
  static const Color neutral900 = Color(0xff0A0D14);
  static const Color neutral800 = Color(0xff161922);
  static const Color neutral700 = Color(0xff20232D);
  static const Color neutral600 = Color(0xff31353F);
  static const Color neutral500 = Color(0xff525866);
  static const Color neutral400 = Color(0xff868C98);
  static const Color neutral300 = Color(0xffCDD0D5);
  static const Color neutral200 = Color(0xffE2E4E9);
  static const Color neutral100 = Color(0xffF6F8FA);
  static const Color neutral0 = white;
  // Blue Color Palette
  static const Color blueDarker = Color(0xff162664);
  static const Color blueDark = Color(0xff253EA7);
  static const Color blueBase = Color(0xff375DFB);
  static const Color blueLight = Color(0xffC2D6FF);
  static const Color blueLighter = Color(0xffEBF1FF);
  // Orange Color Palette
  static const Color orangeDarker = Color(0xff6E330C);
  static const Color orangeDark = Color(0xffC2540A);
  static const Color orangeBase = Color(0xffF17B2C);
  static const Color orangeLight = Color(0xffFFDAC2);
  static const Color orangeLighter = Color(0xffFEF3EB);
  // Yellow Color Palette
  static const Color yellowDarker = Color(0xff693D11);
  static const Color yellowDark = Color(0xffB47818);
  static const Color yellowBase = Color(0xffF2AE40);
  static const Color yellowLight = Color(0xffFBDFB1);
  static const Color yellowLighter = Color(0xffFEF7EC);
  // Red Color Palette
  static const Color redDarker = Color(0xff710E21);
  static const Color redDark = Color(0xffAF1D38);
  static const Color redBase = Color(0xffDF1C41);
  static const Color redLight = Color(0xffF8C9D2);
  static const Color redLighter = Color(0xffFDEDF0);
  // Green Color Palette
  static const Color greenDarker = Color(0xff176448);
  static const Color greenDark = Color(0xff2D9F75);
  static const Color greenBase = Color(0xff38C793);
  static const Color greenLight = Color(0xffCBF5E5);
  static const Color greenLighter = Color(0xffEFFAF6);
  // Purple Color Palette
  static const Color purpleDarker = Color(0xff2B1664);
  static const Color purpleDark = Color(0xff5A36BF);
  static const Color purpleBase = Color(0xff6E3FF3);
  static const Color purpleLight = Color(0xffCAC2FF);
  static const Color purpleLighter = Color(0xffEEEBFF);
  // Pink Color Palette
  static const Color pinkDarker = Color(0xff620F6C);
  static const Color pinkDark = Color(0xff9C23A9);
  static const Color pinkBase = Color(0xffE255F2);
  static const Color pinkLight = Color(0xffF9C2FF);
  static const Color pinkLighter = Color(0xffFDEBFF);
  // Teal Color Palette
  static const Color tealDarker = Color(0xff164564);
  static const Color tealDark = Color(0xff1F87AD);
  static const Color tealBase = Color(0xff35B9E9);
  static const Color tealLight = Color(0xffC2EFFF);
  static const Color tealLighter = Color(0xffEBFAFF);
  static const Color boxShadow = Color(0x1B1C1D0F);

  // Primary Colo Token

  static const Color primaryDark = blueDark;
  static const Color primaryBase = blueBase;
  static const Color primaryLight = blueLight;
  static const Color primaryLighter = blueLighter;
  // Background Color Tokens
  static const Color bgStrong900 = neutral900;
  static const Color bgSurface700 = neutral700;
  static const Color bgSoft200 = neutral200;
  static const Color bgWeak100 = neutral100;
  static const Color bgWhite0 = white;
  // Text Colors
  static const Color textMain900 = neutral900;
  static const Color textSub500 = neutral500;
  static const Color textSoft400 = neutral400;
  static const Color textDisabled300 = neutral300;
  static const Color textWhite0 = white;
  // Stroke Colors
  static const Color strokeStrong900 = neutral900;
  static const Color strokeSub300 = neutral300;
  static const Color strokeSoft200 = neutral200;
  static const Color strokeDisabled100 = neutral100;
  static const Color strokeWhite0 = neutral0;
  // State Colo Tokens
  static const Color stateSuccess = greenBase;
  static const Color stateWarning = orangeBase;
  static const Color stateError = redBase;
  static const Color stateInformation = blueBase;
  static const Color stateAway = yellowBase;
  static const Color stateFeature = purpleBase;
  static const Color stateNeutral = neutral400;
  static const Color stateVerified = tealBase;
  //Icon Color Tokens
  static const Color iconStrong900 = neutral900;
  static const Color iconSub500 = neutral500;
  static const Color iconSoft400 = neutral400;
  static const Color iconDisabled300 = neutral300;
  static const Color iconWhite0 = white;

  // Additional Text Color Tokens
  static const Color textPrimary = textMain900;
  static const Color textSecondary = textSub500;
  static const Color textTertiary = textSoft400;
  static const Color textDisabled = textDisabled300;

  // Border Color Tokens
  static const Color borderPrimary = strokeStrong900;
  static const Color borderSecondary = strokeSub300;
  static const Color borderSoft = strokeSoft200;
  static const Color borderDisabled = strokeDisabled100;
  static const Color borderWhite = strokeWhite0;

  // Dark Theme Text Color Tokens
  static const Color darkTextPrimary = textWhite0;
  static const Color darkTextSecondary = neutral200;
  static const Color darkTextTertiary = neutral300;
  static const Color darkTextDisabled = neutral400;

  // Dark Theme Border Color Tokens
  static const Color darkBorderPrimary = strokeWhite0;
  static const Color darkBorderSecondary = neutral100;
  static const Color darkBorderSoft = neutral200;
  static const Color darkBorderDisabled = neutral300;
  static const Color darkBorderWhite = white;

  static List<Color> baseList = [
    greenBase,
    blueBase,
    yellowBase,
    redBase,
    purpleBase,
    pinkBase,
    orangeBase,
    tealBase,
  ];
  static Color baseColors(int index) => baseList[index % baseList.length];

  static List<Color> lighterList = [
    greenLighter,
    blueLighter,
    yellowLighter,
    redLighter,
    purpleLighter,
    pinkLighter,
    orangeLighter,
    tealLighter,
  ];
  static Color lighterColors(int index) =>
      lighterList[index % lighterList.length];

  static List<Color> lightList = [
    greenLight,
    blueLight,
    yellowLight,
    redLight,
    purpleLight,
    pinkLight,
    orangeLight,
    tealLight,
  ];
  static Color lightColors(int index) => lightList[index % lightList.length];

  static List<Color> darkerList = [
    greenDarker,
    blueDarker,
    yellowDarker,
    redDarker,
    purpleDarker,
    pinkDarker,
    orangeDarker,
    tealDarker,
  ];
  static Color darkerColors(int index) => darkerList[index % darkerList.length];

  static List<Color> darkList = [
    greenDark,
    blueDark,
    yellowDark,
    redDark,
    purpleDark,
    pinkDark,
    orangeDark,
    tealDark,
  ];
  static Color darkColors(int index) => darkList[index % darkList.length];

  static Color dynamicTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextPrimary
        : textPrimary;
  }

  // Brand Colors (extracted from HiraPlus icon)
  static const Color brandDarkGreen = Color(0xFF1B3932); // background
  static const Color brandLightGreen = Color(0xFFC6E3B2); // band
  static const Color brandWhite = Color(0xFFFFFFFF);
  static const Color brandGreen = Color(0xFF188064);
  static const Color splashGreen = Color(0xFF12342B); // H and background
}
