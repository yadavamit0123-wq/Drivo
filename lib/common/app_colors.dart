import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF001CAD);
  static const Color secondary = Color(0xFF001CAD);
  static const Color secondaryDark = Color.fromRGBO(84, 197, 248, 1);

// Common colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color.fromARGB(200, 218, 212, 212);
  static const Color green = Color(0xff0BC333);
  static const Color greyHeader = Color(0xFF99AABE);
  static const Color transparent = Colors.transparent;
  static const Color yellowColor = Color(0xFFCFA829);
  static const Color lightGreen = Color(0XFF14B014);

  static const MaterialColor darkGrey = Colors.grey;
  static const Color red = Color(0xffFB270B);
  static const MaterialColor blue = Colors.blue;
  static const MaterialColor orange = Colors.orange;
  static const Color errorLight = Color(0xFFc4204e);
  static const Color greyHintColor = Color(0xFF696969);
  static Color textSelectionColor =
      greyHintColor.withAlpha((0.5 * 255).toInt());
  static const Color goldenColor = Color(0xffFFD700);

  static const Color buttonColor = Color(0xFF001CAD);
  static const Color buttonTextColor = Color(0xFFFFFFFF);

  static const Color hintColor = Color(0xFF565D6D);
  static const Color hintColorGrey = Color(0xFF171A1F);
  static const Color borderColor = Color(0xFFF3F4F6);
  static const Color waitingForApprovel = Color(0xFFFBC02D);
  static const Color uploadedAndApproved = Color(0xFF001CAD);
  static const Color uploadedAndDeclined = Color(0xFFD32F2F);
  static const Color borderColors = Color(0xFFDEE1E6);
  static const Color textColor = Color(0xFF19191F);
  static const Color redBackground = Color(0xFFE0D0D1);
  static const Color toggleButtonColor = Color(0xFFBDC1CA);

  // bottom navigationbar Light mode colors
  static const Color bottomNavigationBarColor = Color(0xFFFFFFFF);
  static const Color bottomNavigationBarShadowColor =
      Color(0x1A000000); // Black with 0.1 opacity
  static const Color bottomNavigationBarSelectedColor = Color(0xFF000000);
  static const Color bottomNavigationBarUnSelectedColor = Color(0xFF565D6D);

  // bottom navigationbar Dark mode colors
  static const Color bottomNavigationBarColorDark =
      Color.fromARGB(255, 8, 9, 10);
  static const Color bottomNavigationBarShadowColorDark =
      Color(0x33000000); // Denser black shadow for dark mode
  static const Color bottomNavigationBarSelectedColorDark = Color(0xFFFFFFFF);
  static const Color bottomNavigationBarUnSelectedColorDark = Color(0xFF99AABE);
}
