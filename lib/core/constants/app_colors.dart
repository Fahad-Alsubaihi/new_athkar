import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ==========================================================
  // DAY MODE (مصادر فقط - يستخدمها AppTheme و Backgrounds)
  // ==========================================================

  static const List<Color> dayGradient = [
    Color(0xFF7D2147),
    Color(0xFF962E46),
    Color(0xFFB23B48),
    Color(0xFFC65250),
    Color(0xFFD9705B),
  ];

  static const Color dayPrimary = Color(0xFFC65250);

  // يستخدم للـ glass / cards فقط
  static const Color dayCardSurface = Color.fromARGB(230, 255, 224, 225);

  // ==========================================================
  // NIGHT MODE
  // ==========================================================

  static const List<Color> nightGradient = [
    Color(0xFF000428),
    Color(0xFF000A31),
    Color(0xFF002A5F),
    Color(0xFF004E92),
  ];

  // static const Color nightPrimary = Color(0xFF004E92);
  // static const Color nightPrimary = Color.fromARGB(255, 80, 125, 198); // لون أفتح بقليل (لإبراز الأزرار)
  static const Color nightPrimary = Color.fromARGB(255, 82, 134, 238);

  static const Color nightCardSurface = Color.fromARGB(200, 0, 0, 0);

  // ==========================================================
  // PROGRESS COLORS (ثابتة - ما تتبع الثيم)
  // ==========================================================

  static const Color morningProgress =
      Color.fromRGBO(162, 47, 47, 1);

  static const Color eveningProgress =
      Color.fromRGBO(0, 27, 78, 1);

  // ==========================================================
  // FIXED COLORS (استخدمها فقط إذا النص لازم يكون ثابت)
  // ==========================================================

  static const Color fixedWhite = Colors.white;
  static const Color fixedBlack = Colors.black;
}
