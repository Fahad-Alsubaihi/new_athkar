import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Baloo';

  // =========================
  // FIXED STYLES (ثابتة للكارد)
  // =========================

  static const TextStyle cardTitleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24, // كان 24
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.35,
  );

  static const TextStyle cardTitleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20, // كان 20
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.35,
  );

  static const TextStyle cardBodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24, // كان 18 (هذا اللي بيرجع نفس إحساس القديم)
    fontWeight: FontWeight.normal,
    color: Colors.white,
    height: 1.8,
  );

  static const TextStyle cardBodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20, // كان 16
    fontWeight: FontWeight.normal,
    color: Colors.white,
    height: 1.8,
  );

  static const TextStyle counter = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30, // كان 27
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle cardSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18, // كان 14
    color: Colors.white70,
  );

  // =========================
  // THEME-AWARE (للشاشات العامة)
  // =========================
  static const TextStyle header = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28, // كان 16
    fontWeight: FontWeight.bold,
    color: Colors.white,
    height: 1.8,
  );
  static TextStyle titleLarge(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: fontFamily) ??
      const TextStyle(fontFamily: fontFamily, fontSize: 20);

  static TextStyle titleMedium(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium?.copyWith(fontFamily: fontFamily) ??
      const TextStyle(fontFamily: fontFamily, fontSize: 16);

  static TextStyle bodyMedium(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium?.copyWith(fontFamily: fontFamily) ??
      const TextStyle(fontFamily: fontFamily, fontSize: 14);

  static TextStyle bodySmall(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: fontFamily) ??
      const TextStyle(fontFamily: fontFamily, fontSize: 12);
}
