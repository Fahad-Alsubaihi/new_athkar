import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:athkar_new/core/constants/app_constants.dart';
import 'package:athkar_new/data/models/city.dart';
import 'package:athkar_new/gen_l10n/app_localizations.dart';
import 'package:athkar_new/services/prayer_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_service.dart';

class ReminderScheduler {
  ReminderScheduler._();

  static const int _prayerBaseId = 1000; // 1000..1999
  static const int _athkarBaseId = 2000; // 2000..2999

  static Timer? _debounce;

  static String _ymd(DateTime dt) =>
      "${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";

  static Future<List<int>> _loadIds(String key) async {
    final sp = await SharedPreferences.getInstance();
    final s = sp.getString(key);
    if (s == null) return [];
    final raw = jsonDecode(s);
    if (raw is! List) return [];
    return raw.map((e) => e as int).toList();
  }

  static Future<void> _saveIds(String key, List<int> ids) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(key, jsonEncode(ids));
  }

  static Future<void> _cancelIds(List<int> ids) async {
    for (final id in ids) {
      await NotificationService.cancel(id);
    }
  }

  /// ✅ Debounce: استخدمها من الـ UI بدل reschedule مباشرة
  static void queueReschedule({
    required City city,
    required bool prayersEnabled,
    required bool athkarEnabled,
    required AppLocalizations l10n,
    int daysAhead = 3,
    Duration debounce = const Duration(milliseconds: 600),
  }) {
    _debounce?.cancel();
    _debounce = Timer(debounce, () {
      reschedule(
        city: city,
        prayersEnabled: prayersEnabled,
        athkarEnabled: athkarEnabled,
        l10n: l10n,
        daysAhead: daysAhead,
      );
    });
  }

  /// نداءها عند فتح التطبيق: تسوي reschedule مرة باليوم فقط
  static Future<void> ensureScheduledToday({
    required City city,
    required bool prayersEnabled,
    required bool athkarEnabled,
    required AppLocalizations l10n,
    int daysAhead = 2,
  }) async {
    final sp = await SharedPreferences.getInstance();
    final today = _ymd(DateTime.now());
    final last = sp.getString(AppConstants.lastScheduleYmdKey);

    if (last == today) return;

    await reschedule(
      city: city,
      prayersEnabled: prayersEnabled,
      athkarEnabled: athkarEnabled,
      l10n: l10n,
      daysAhead: daysAhead,
    );

    await sp.setString(AppConstants.lastScheduleYmdKey, today);
  }

  static Future<void> reschedule({
    required City city,
    required bool prayersEnabled,
    required bool athkarEnabled,
    required AppLocalizations l10n,
    int daysAhead = 14,
    bool useForegroundFallback = false,
  }) async {
    await NotificationService.init();
    await NotificationService.requestPermissionIfNeeded();

    // ✅ إلغاء القديم: فقط IDs اللي فعلاً كانت مجدولة
    final oldPrayerIds = await _loadIds(AppConstants.scheduledPrayerIdsKey);
    final oldAthkarIds = await _loadIds(AppConstants.scheduledAthkarIdsKey);
    await _cancelIds(oldPrayerIds);
    await _cancelIds(oldAthkarIds);

    final now = DateTime.now();
    final startDay = DateTime(now.year, now.month, now.day);

    final items = <PendingNotification>[];
    final newPrayerIds = <int>[];
    final newAthkarIds = <int>[];

    for (int d = 0; d < daysAhead; d++) {
      final day = startDay.add(Duration(days: d));

      // ✅ حساب أوقات الصلاة لهذا اليوم للمدينة المختارة (عن طريق PrayerService)
      // نخلي "now" داخل نفس اليوم (12:00) عشان يطلع حساب اليوم صحيح
      final times = PrayerService.computeForDay(city: city, day: day);
      if (times == null) continue;

// وبعدين تستخدم city.fajr / city.asr ...

      // ====== صلوات ======
      if (prayersEnabled) {
       _addPrayer(items,
          idsOut: newPrayerIds,
          id: _prayerBaseId + d * 10 + 0,
          key: 'fajr',
          when: times.fajr,
          now: now,
          l10n: l10n,
        );

        _addPrayer(items,
            idsOut: newPrayerIds,
            id: _prayerBaseId + d * 10 + 1,
            key: 'dhuhr',
            when: times.dhuhr,
            now: now,
            l10n: l10n);

        _addPrayer(items,
            idsOut: newPrayerIds,
            id: _prayerBaseId + d * 10 + 2,
            key: 'asr',
            when: times.asr,
            now: now,
            l10n: l10n);

        _addPrayer(items,
            idsOut: newPrayerIds,
            id: _prayerBaseId + d * 10 + 3,
            key: 'maghrib',
            when: times.maghrib,
            now: now,
            l10n: l10n);

        _addPrayer(items,
            idsOut: newPrayerIds,
            id: _prayerBaseId + d * 10 + 4,
            key: 'isha',
            when: times.isha,
            now: now,
            l10n: l10n);
      }

      // ====== أذكار ======
      if (athkarEnabled) {
        final fajr = times.fajr;
        final asr = times.asr;

        // ✅ بعد الفجر بساعة
        final morning = fajr?.add(const Duration(hours: 1));
        // ✅ بعد العصر بساعة
        final evening = asr?.add(const Duration(hours: 1));

        _addAthkar(items,
            idsOut: newAthkarIds,
            id: _athkarBaseId + d * 10 + 0,
            which: 'morning',
            when: morning,
            now: now,
            l10n: l10n);

        _addAthkar(items,
            idsOut: newAthkarIds,
            id: _athkarBaseId + d * 10 + 1,
            which: 'evening',
            when: evening,
            now: now,
            l10n: l10n);
      }
    }

    await NotificationService.scheduleBatchSmart(items: items);

    await _saveIds(AppConstants.scheduledPrayerIdsKey, newPrayerIds);
    await _saveIds(AppConstants.scheduledAthkarIdsKey, newAthkarIds);

    if (useForegroundFallback && prayersEnabled && Platform.isAndroid) {
      // حاليا Off
      // ignore: avoid_print
      print('Foreground fallback requested (Android)');
    }
  }

  static void _addPrayer(
    List<PendingNotification> items, {
    required List<int> idsOut,
    required int id,
    required String key,
    required DateTime? when,
    required DateTime now,
    required AppLocalizations l10n,
  }) {
    if (when == null) return;
    if (!when.isAfter(now)) return;

    final prayerName = _prayerName(l10n, key);

    items.add(PendingNotification(
      id: id,
      title: l10n.prayerReminderTitle,
      body: l10n.prayerReminderBody(prayerName),
      when: when,
      channelId: NotificationService.channelPrayers,
    ));
    idsOut.add(id);
  }

  static void _addAthkar(
    List<PendingNotification> items, {
    required List<int> idsOut,
    required int id,
    required String which,
    required DateTime? when,
    required DateTime now,
    required AppLocalizations l10n,
  }) {
    if (when == null) return;
    if (!when.isAfter(now)) return;

    final title = l10n.athkarReminderTitle;
    final body = which == 'morning'
        ? l10n.athkarMorningReminderBody
        : l10n.athkarEveningReminderBody;

    items.add(PendingNotification(
      id: id,
      title: title,
      body: body,
      when: when,
      channelId: NotificationService.channelAthkar,
    ));
    idsOut.add(id);
  }

  static String _prayerName(AppLocalizations l10n, String key) {
    switch (key) {
      case 'fajr':
        return l10n.fajr;
      case 'dhuhr':
        return l10n.dhuhr;
      case 'asr':
        return l10n.asr;
      case 'maghrib':
        return l10n.maghrib;
      case 'isha':
        return l10n.isha;
      default:
        return key;
    }
  }
}