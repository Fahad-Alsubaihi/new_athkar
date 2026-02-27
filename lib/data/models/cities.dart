import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/shared_preferences_helper.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../services/location_service.dart';
import '../../services/prayer_service.dart';
import '../../services/reminder_scheduler.dart';
import 'city.dart';

enum AthkarMode { morning, evening }

class CityProvider with ChangeNotifier {
  List<City> cities = [];
  City? selectedCity;

  bool _loaded = false;
  static const String _selectedCityKey = AppConstants.selectedCityKey;

  AthkarMode mode = AthkarMode.morning;
  bool isDaytime = true;

  // manual override (from Body tabs)
  bool manualOverride = false;

  String _makeKey(double lat, double lon) =>
      "${lat.toStringAsFixed(6)},${lon.toStringAsFixed(6)}";

  String _cityKey(City c) => _makeKey(c.latitude, c.longitude);

  String get selectedCityKey =>
      selectedCity == null ? "no_city" : _cityKey(selectedCity!);

  // =========================
  // Azan helper (delegates to PrayerService)
  // =========================
  void _syncPrayerTimes(City city, DateTime now) {
    PrayerService.updateCityPrayerTimes(city: city, now: now);
  }

  bool get realCityIsDaytime {
    final n = DateTime.now();
    final city = selectedCity;
    if (city == null) return true;

    _syncPrayerTimes(city, n);

    final f = city.fajr;
    final a = city.asr;

    if (f != null && a != null) {
      return (n.isAtSameMomentAs(f) || n.isAfter(f)) && n.isBefore(a);
    }
    return true;
  }

  Future<void> loadCities() async {
    if (_loaded) return;
    _loaded = true;

    final jsonString = await rootBundle.loadString(AppConstants.citiesJson);
    final List<dynamic> jsonList = json.decode(jsonString);
    cities = jsonList.map((e) => City.fromJson(e)).toList();

    if (cities.isEmpty) {
      selectedCity = null;
      mode = AthkarMode.morning;
      isDaytime = true;
      manualOverride = false;
      notifyListeners();
      return;
    }

    // ✅ (جديد) أعد إضافة "موقعي الحالي" لو كان محفوظ (بدون جلب GPS)
    final lat = await SharedPreferencesHelper.getDouble(
        AppConstants.currentLocationLatKey);
    final lng = await SharedPreferencesHelper.getDouble(
        AppConstants.currentLocationLngKey);
    final label = await SharedPreferencesHelper.getString(
        AppConstants.currentLocationLabelKey);

    if (lat != null && lng != null && (label?.isNotEmpty ?? false)) {
      final savedLocCity = City(
        name: {
          "ar": label!,
          "en": label,
        },
        latitude: lat,
        longitude: lng,
      );

      // احذف نسخة قديمة لو موجودة ثم ضفها أول القائمة
      cities.removeWhere((c) =>
          (c.latitude == lat && c.longitude == lng) ||
          (c.name['ar'] == label) ||
          (c.name['en'] == label));
      cities.insert(0, savedLocCity);
    }

    final savedKey = await SharedPreferencesHelper.getString(_selectedCityKey);

    if (savedKey != null && savedKey.isNotEmpty) {
      selectedCity = cities.firstWhere(
        (c) => _cityKey(c) == savedKey,
        orElse: () => cities.first,
      );
    } else {
      selectedCity = cities.first;
    }

    refreshMode();
  }

  /// ✅ زر: استخدم موقعي الحالي
  /// - مهم جدًا: نضيف "موقعي الحالي" داخل cities عشان Dropdown ما ينكسر
  Future<bool> selectCurrentLocation({
    required bool prayersEnabled,
    required bool athkarEnabled,
    required AppLocalizations l10n,
  }) async {
    final pos = await LocationService.getCurrentPositionSafe();
    if (pos == null) return false;

    // ✅ (جديد) خزّن الإحداثيات + الاسم + وقت التحديث (بدون مفاتيح عشوائية)
    await SharedPreferencesHelper.setDouble(
      AppConstants.currentLocationLatKey,
      pos.latitude,
    );
    await SharedPreferencesHelper.setDouble(
      AppConstants.currentLocationLngKey,
      pos.longitude,
    );
    await SharedPreferencesHelper.setString(
      AppConstants.currentLocationLabelKey,
      l10n.myCurrentLocation,
    );
    await SharedPreferencesHelper.setInt(
      AppConstants.currentLocationUpdatedAtMsKey,
      DateTime.now().millisecondsSinceEpoch,
    );

    final locCity = City(
      name: {
        "ar": l10n.myCurrentLocation,
        "en": l10n.myCurrentLocation,
      },
      latitude: pos.latitude,
      longitude: pos.longitude,
    );

    // احذف نسخة قديمة لو موجودة ثم ضفها أول القائمة
    cities.removeWhere((c) =>
        (c.name['ar'] == l10n.myCurrentLocation) ||
        (c.name['en'] == l10n.myCurrentLocation));
    cities.insert(0, locCity);

    await selectCity(locCity);

    // جدول/حدّث الإشعارات (مع debounce)
    ReminderScheduler.queueReschedule(
      city: locCity,
      prayersEnabled: prayersEnabled,
      athkarEnabled: athkarEnabled,
      l10n: l10n,
    );

    notifyListeners();
    return true;
  }

  Future<void> selectCity(City city) async {
    selectedCity = city;
    await SharedPreferencesHelper.setString(_selectedCityKey, _cityKey(city));

    manualOverride = false;
    refreshMode();
  }

  Future<void> setManualMode(bool day) async {
    manualOverride = true;
    isDaytime = day;
    mode = day ? AthkarMode.morning : AthkarMode.evening;
    notifyListeners();
  }

  void clearManualOverride({DateTime? now}) {
    manualOverride = false;
    refreshMode(now: now);
  }

  void refreshMode({DateTime? now}) {
    if (manualOverride) {
      notifyListeners();
      return;
    }

    final n = now ?? DateTime.now();
    final city = selectedCity;

    if (city == null) {
      mode = AthkarMode.morning;
      isDaytime = true;
      notifyListeners();
      return;
    }

    _syncPrayerTimes(city, n);

    final f = city.fajr;
    final a = city.asr;
    final m = city.maghrib;

    if (f == null || a == null || m == null) {
      isDaytime = true;
      mode = AthkarMode.morning;
      notifyListeners();
      return;
    }

    final day = (n.isAtSameMomentAs(f) || n.isAfter(f)) && n.isBefore(a);

    isDaytime = day;
    mode = day ? AthkarMode.morning : AthkarMode.evening;

    notifyListeners();
  }

  void computeSunTimes(DateTime date) {
    clearManualOverride(now: date);
  }

  Future<void> resetDefaults() async {
    if (cities.isEmpty) return;
    await selectCity(cities.first);
  }
}