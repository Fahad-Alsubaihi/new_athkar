import 'dart:convert';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/utils/shared_preferences_helper.dart';
import '../core/constants/app_constants.dart';
import '../data/models/citations.dart';

class SwiperMethods {
  static final SwiperController controller = SwiperController();

  static void goNext(int index, bool time) {
    controller.next();
  }

  static const String _kProgress = AppConstants.progressKey;

  static String _todayYmd() {
    final now = DateTime.now();
    final d = DateTime(now.year, now.month, now.day);
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return "${d.year}-$mm-$dd";
  }

  static String _modeStr(bool isDay) => isDay ? "morning" : "evening";

  static Future<void> saveProgress({
    required String cityKey,
    required bool isDay,
    required int index,
    required int counter,
  }) async {
    final payload = <String, dynamic>{
      "cityKey": cityKey,
      "ymd": _todayYmd(),
      "mode": _modeStr(isDay),
      "index": index,
      "counter": counter,
    };

    await SharedPreferencesHelper.setString(_kProgress, jsonEncode(payload));
    debugPrint("SAVE $_kProgress => $payload");
  }

  static Future<void> saveProgressIfCityMode({
    required String cityKey,
    required bool isDay,
    required bool cityIsDaytime, // لازم يكون REAL city time
    required int index,
    required int counter,
  }) async {
    if (isDay != cityIsDaytime) {
      debugPrint(
        "SKIP SAVE $_kProgress (manual mode) => isDay=$isDay cityIsDaytime=$cityIsDaytime",
      );
      return;
    }
    await saveProgress(
      cityKey: cityKey,
      isDay: isDay,
      index: index,
      counter: counter,
    );
  }

  static Future<Map<String, dynamic>?> _loadProgressRaw() async {
    final raw = await SharedPreferencesHelper.getString(_kProgress);
    if (raw == null || raw.isEmpty) return null;

    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      await SharedPreferencesHelper.remove(_kProgress);
      debugPrint("CORRUPT $_kProgress -> cleared. err=$e");
      return null;
    }
  }

static bool _isValidDayOnly({
  required Map<String, dynamic> m,
}) {
  return m["ymd"] == _todayYmd();
}


  static Future<void> stopPoint({
    required List<Citations> data,
    required String cityKey,
    bool? cityIsDaytime, // لازم يكون REAL city time
  }) async {
    if (data.isEmpty) return;

    final isDay = data[0].isDay ?? true;
    final viewMode = _modeStr(isDay);

    final saved = await _loadProgressRaw();

    if (saved == null) {
      for (final e in data) {
        e.reset();
      }
      controller.move(0);
      debugPrint("No progress -> reset (city=$cityKey mode=$viewMode)");
      return;
    }

    // 1) اليوم/المدينة
final okDay = _isValidDayOnly(m: saved);
if (!okDay) {
  await SharedPreferencesHelper.remove(_kProgress);
  for (final e in data) {
    e.reset();
  }
  controller.move(0);
  debugPrint("INVALID $_kProgress (day changed) -> cleared. stored=$saved");
  debugPrint("No VALID progress -> reset (mode=$viewMode)");
  return;
}


    final savedMode = "${saved["mode"]}";

    // 2) وقت المدينة الحقيقي تغيّر => امسح
    // ✅ حماية: لا نمسح إلا إذا أنت فعلاً تعرض مود المدينة الحقيقي
    if (cityIsDaytime != null) {
      final cityModeNow = _modeStr(cityIsDaytime);

      // إذا العرض الحالي = وقت المدينة الحقيقي، والمحفوظه كانت مود ثاني => انتهى وقتها => امسح
      if (viewMode == cityModeNow && savedMode != cityModeNow) {
        await SharedPreferencesHelper.remove(_kProgress);
        for (final e in data) {
          e.reset();
        }
        controller.move(0);
        debugPrint(
          "CITY MODE CHANGED -> cleared $_kProgress. "
          "(city=$cityKey savedMode=$savedMode cityModeNow=$cityModeNow stored=$saved)",
        );
        debugPrint("No VALID progress -> reset (city=$cityKey mode=$viewMode)");
        return;
      }

      // 3) عرض يدوي مخالف لوقت المدينة -> لا تمسح
      if (isDay != cityIsDaytime) {
        for (final e in data) {
          e.reset();
        }
        controller.move(0);
        debugPrint(
          "Manual mode view -> start fresh WITHOUT clearing saved. "
          "(city=$cityKey viewMode=$viewMode cityModeNow=$cityModeNow stored=$saved)",
        );
        return;
      }
    }

    // 4) إذا المود ما يطابق المحفوظ (وما عندنا cityIsDaytime أو ما طبقنا شروط فوق) => لا نمسح
    if (savedMode != viewMode) {
      for (final e in data) {
        e.reset();
      }
      controller.move(0);
      debugPrint(
        "MODE MISMATCH -> start fresh WITHOUT clearing. "
        "(city=$cityKey viewMode=$viewMode savedMode=$savedMode stored=$saved)",
      );
      return;
    }

    // Restore
    final savedIndex = (saved["index"] is int)
        ? saved["index"] as int
        : int.tryParse("${saved["index"]}") ?? 0;

    final savedCounter = (saved["counter"] is int)
        ? saved["counter"] as int
        : int.tryParse("${saved["counter"]}") ?? 0;

    final i = savedIndex.clamp(0, data.length - 1);
    final maxCounter = data[i].counter ?? 0;
    final c = savedCounter.clamp(0, maxCounter);

    for (int k = 0; k < data.length; k++) {
      if (k < i) {
        data[k].complete();
      } else {
        data[k].reset();
      }
    }

    data[i].currentc = c;
    data[i].notifyListeners();

    final moveTo = (data[i].counter == data[i].currentc) ? (i + 1) : i;
    controller.move(moveTo.clamp(0, data.length - 1));

    debugPrint(
      "RESTORE (city=$cityKey mode=$viewMode) index=$i counter=$c moveTo=$moveTo",
    );
  }

  static Future<void> clearTodayProgress({
    required List<Citations> morningData,
    required List<Citations> nightData,
  }) async {
    await SharedPreferencesHelper.remove(_kProgress);

    void resetList(List<Citations> list) {
      for (final c in list) {
        c.reset();
        c.notifyListeners();
      }
    }

    resetList(morningData);
    resetList(nightData);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.move(0);
    });

    debugPrint("CLEAR progress: $_kProgress");
  }
}
