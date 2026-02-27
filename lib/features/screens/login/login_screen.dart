import 'package:flutter/material.dart';

import '../../../size_config.dart';
import '../components/body.dart';
import '../components/settings_drawer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Future<void> Function()? _resetProgress;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      body: Body(
        onRegisterReset: (fn) => _resetProgress = fn,
      ),
      drawer: SettingsDrawer(
        // isDay موجود عندك في الكونستركتر عشان ما نكسر الملفات القديمة
        // لكن ما نحتاجه فعليًا بعد ما صار الثيم يتبدّل من MaterialApp
        // isDay: true,
        onResetProgress: _resetProgress,
      ),
      // endDrawer: SettingsDrawer(
      //   // isDay موجود عندك في الكونستركتر عشان ما نكسر الملفات القديمة
      //   // لكن ما نحتاجه فعليًا بعد ما صار الثيم يتبدّل من MaterialApp
      //   // isDay: true,
      //   onResetProgress: _resetProgress,
      // ),
    );
  }
}
