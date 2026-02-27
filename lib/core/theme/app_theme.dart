import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.dayPrimary,
    scaffoldBackgroundColor: Colors.transparent,
    fontFamily: 'Baloo',

    colorScheme: const ColorScheme.light(
      primary: AppColors.dayPrimary,

      // خلي السطح أبيض/فاتح
      surface: Colors.white,
      // النص فوق السطح يكون غامق
      onSurface: Colors.black87,

      // surfaceDim: Colors.grey, // لون خلفية العناصر المفعلة (مثل TextField)
      
    ),

    // ✅ نصوص light لازم تكون غامقة (مو بيضاء)
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: 20),
      bodyMedium: TextStyle(fontSize: 16),
    ),

    iconTheme: const IconThemeData(color: Colors.black87),
    dividerColor: Colors.black12,

    drawerTheme: const DrawerThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black26),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.dayPrimary),
      ),
      labelStyle: const TextStyle(color: Colors.black87),
    ),

    switchTheme: SwitchThemeData(
      
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.dayPrimary;
        return Colors.grey;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.dayPrimary.withOpacity(0.35);
        return Colors.grey.withOpacity(0.35);
      }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        trackOutlineWidth: WidgetStateProperty.all(0),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.dayPrimary),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black87,
        side: const BorderSide(color: Colors.black26),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
    ),

    dropdownMenuTheme: const DropdownMenuThemeData(
      textStyle: TextStyle(color: Colors.black87),
    ),
  );

  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.nightPrimary,
    scaffoldBackgroundColor: Colors.transparent,
    fontFamily: 'Baloo',

    colorScheme: const ColorScheme.dark(
      primary: AppColors.nightPrimary,
      surface: Color(0xFF111111),
      onSurface: Colors.white,
    ),

    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: 20),
      bodyMedium: TextStyle(fontSize: 16),
    ),

    iconTheme: const IconThemeData(color: Colors.white),
    dividerColor: Colors.white24,

    drawerTheme: const DrawerThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white30),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.nightPrimary),
      ),
      labelStyle: const TextStyle(color: Colors.white),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.nightPrimary;
        return Colors.grey;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.nightPrimary.withOpacity(0.35);
        return Colors.grey.withOpacity(0.35);
      }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        trackOutlineWidth: WidgetStateProperty.all(0),
        
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.nightPrimary),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white30),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
    ),

    dropdownMenuTheme: const DropdownMenuThemeData(
      textStyle: TextStyle(color: Colors.white),
    ),
  );
}
