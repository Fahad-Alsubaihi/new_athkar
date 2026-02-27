import 'package:flutter/foundation.dart';
import '../core/utils/shared_preferences_helper.dart';
import '../core/constants/app_constants.dart';

class SettingsModel extends ChangeNotifier {
  static const String _kVibration = AppConstants.vibrationKey;
  static const String _kLanguageCode = AppConstants.languageKey;
  static const String _kFontScale = AppConstants.fontScaleKey;
  static const String _kPrayerReminder = AppConstants.prayerReminderKey;
  static const String _kAthkarReminder = AppConstants.athkarReminderKey;
  static const String _kLocUpdatedMs = AppConstants.currentLocationUpdatedAtMsKey;
  
  bool _vibration = false;
  bool _prayerReminder = false;
  bool _athkarReminder = false;
  bool _loaded = false;
  String languageCode = 'ar';
  double _fontScale = 1.0;
  DateTime? _lastLocationUpdate;


  double get fontScale => _fontScale;
  bool get vibration => _vibration;
  bool get prayerReminder => _prayerReminder;
  bool get athkarReminder => _athkarReminder;
  DateTime? get lastLocationUpdate => _lastLocationUpdate;


  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;

    // vibration
    final v = await SharedPreferencesHelper.getBool(_kVibration);
    _vibration = v ?? false;

    // language
    final lang = await SharedPreferencesHelper.getString(_kLanguageCode);
    languageCode = lang ?? 'ar';

    // font scale
    final fs = await SharedPreferencesHelper.getDouble(_kFontScale);
    _fontScale = (fs ?? 1.0).clamp(0.85, 1.25);

    // notifications
    final pr = await SharedPreferencesHelper.getBool(_kPrayerReminder);
    _prayerReminder = pr ?? false;

    final ar = await SharedPreferencesHelper.getBool(_kAthkarReminder);
    _athkarReminder = ar ?? false;

    final ms = await SharedPreferencesHelper.getInt(_kLocUpdatedMs);
    _lastLocationUpdate =
        (ms == null) ? null : DateTime.fromMillisecondsSinceEpoch(ms);


    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    languageCode = code;
    await SharedPreferencesHelper.setString(_kLanguageCode, code);
    notifyListeners();
  }

  Future<void> setVibration(bool value) async {
    _vibration = value;
    await SharedPreferencesHelper.setBool(_kVibration, value);
    notifyListeners();
  }

  // ✅ تحديث حجم الخط
  Future<void> setFontScale(double value) async {
    _fontScale = value.clamp(0.85, 1.25);
    await SharedPreferencesHelper.setDouble(_kFontScale, _fontScale);
    notifyListeners();
  }

    // ✅ toggle prayer reminders
  Future<void> setPrayerReminder(bool value) async {
    _prayerReminder = value;
    await SharedPreferencesHelper.setBool(_kPrayerReminder, value);
    notifyListeners();
  }

  // ✅ toggle athkar reminders
  Future<void> setAthkarReminder(bool value) async {
    _athkarReminder = value;
    await SharedPreferencesHelper.setBool(_kAthkarReminder, value);
    notifyListeners();
  }



  Future<void> setLastLocationUpdate(DateTime? dt) async {
    _lastLocationUpdate = dt;
    if (dt == null) {
      await SharedPreferencesHelper.remove(_kLocUpdatedMs);
    } else {
      await SharedPreferencesHelper.setInt(
          _kLocUpdatedMs, dt.millisecondsSinceEpoch);
    }
    notifyListeners();
  }



  // ✅ يرجّع الإعدادات الافتراضية فعلياً
  Future<void> resetDefaults() async {
    _vibration = false;
    languageCode = 'ar';
    _fontScale = 1.0;
    _prayerReminder = false;
    _athkarReminder = false;

    await SharedPreferencesHelper.setBool(_kVibration, _vibration);
    await SharedPreferencesHelper.setString(_kLanguageCode, languageCode);
    await SharedPreferencesHelper.setDouble(_kFontScale, _fontScale);
    await SharedPreferencesHelper.setBool(_kPrayerReminder, _prayerReminder);
    await SharedPreferencesHelper.setBool(_kAthkarReminder, _athkarReminder);

    notifyListeners();
  }
}
