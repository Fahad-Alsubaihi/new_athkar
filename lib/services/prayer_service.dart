import 'package:athkar_new/data/models/city.dart';
import 'package:athkar_new/gen_l10n/app_localizations.dart';
import 'package:hijri/hijri_calendar.dart';



enum PrayerTickerKind { remaining, since }

class PrayerTickerResult {
  final String text;
  final String activeKey; // اللي نلوّنه بالجدول
  final PrayerTickerKind kind;

  const PrayerTickerResult({
    required this.text,
    required this.activeKey,
    required this.kind,
  });
}

class PrayerService {
  static const Duration _adhanWindow = Duration(minutes: 30);

  // =========================
  // 1) Update city prayer times (used by CityProvider)
  // =========================
  static void updateCityPrayerTimes({
    required City city,
    required DateTime now,
  }) {
    city.computePrayerTimes(now);
    _applyRamadanIsha(city, now);
  }

  // =========================
  // 2) Ramadan helpers
  // =========================
  static bool _isRamadan(DateTime now) {
    try {
      final h = HijriCalendar.fromDate(now);
      return h.hMonth == 9;
    } catch (_) {
      final h = HijriCalendar.now();
      return h.hMonth == 9;
    }
  }

  static void _applyRamadanIsha(City city, DateTime now) {
    if (!_isRamadan(now)) return;
    final isha = city.isha;
    if (isha == null) return;
    city.isha = isha.add(const Duration(minutes: 30));
  }

  // =========================
  // 3) Formatting
  // =========================
  static String fmtRemaining(Duration d) {
    if (d.inSeconds <= 0) return "0:00:00";
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return "${h}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
    } else {
      return "${m}:${s.toString().padLeft(2, '0')}";
    } 
  }

  // =========================
  // 4) Localized prayer name (Friday: Dhuhr -> Jumuah)
  // =========================
  static String nameFor(AppLocalizations l10n, String key, DateTime now) {
    if (key == 'dhuhr' && now.weekday == DateTime.friday) {
      return l10n.jumuah;
    }
    switch (key) {
      case 'fajr':
        return l10n.fajr;
      case 'sunrise':
        return l10n.sunrise;
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

  static PrayerTickerResult? buildTicker({
  required City city,
  required DateTime now,
  required AppLocalizations l10n,
}) {
  final fajr = city.fajr;
  final sunrise = city.sunrise;
  final dhuhr = city.dhuhr;
  final asr = city.asr;
  final maghrib = city.maghrib;
  final isha = city.isha;

  if (fajr == null || dhuhr == null || asr == null || maghrib == null || isha == null) {
    return null;
  }

  final items = <({String key, DateTime time})>[
    (key: 'fajr', time: fajr),
    if (sunrise != null) (key: 'sunrise', time: sunrise),
    (key: 'dhuhr', time: dhuhr),
    (key: 'asr', time: asr),
    (key: 'maghrib', time: maghrib),
    (key: 'isha', time: isha),
  ];

  for (int i = 0; i < items.length; i++) {
    final p = items[i];

    // نفس شرطك: يا أنه بعده (الصلاة القادمة) أو داخل نافذة 30 دقيقة بعده
    if (p.time.isAfter(now) || now.isBefore(p.time.add(_adhanWindow))) {
      final dif = now.difference(p.time);
      final name = nameFor(l10n, p.key, now);

      if (dif > Duration.zero) {
        // داخل نافذة "منذ"
        return PrayerTickerResult(
          text: "$name ${l10n.since} : ${fmtRemaining(dif)}",
          activeKey: p.key,
          kind: PrayerTickerKind.since,
        );
      } else if (dif < Duration.zero) {
        // باقي على الوقت
        return PrayerTickerResult(
          text: "$name ${l10n.remaining} : ${fmtRemaining(-dif)}",
          // هنا الصلاة النشطة غالباً هي اللي قبلها، لكن لو تبيها = p.key مو مشكلة
          // إذا تبي "النشطة" تكون السابقة: خليها items[i-1] مع معالجة i==0
          activeKey: p.key,
          kind: PrayerTickerKind.remaining,
        );
      }
      break;
    }
  }

  // بعد العشاء: فجر بكرة
  final next = (key: 'fajr', time: fajr.add(const Duration(days: 1)));
  final name = nameFor(l10n, next.key, now);
  final rem = next.time.difference(now);

  return PrayerTickerResult(
    text: "$name ${l10n.remaining} : ${fmtRemaining(rem)}",
    activeKey: 'fajr', // أو أي شيء تبيه
    kind: PrayerTickerKind.remaining,
  );
}

static PrayerTimes? computeForDay({
  required City city,      // المدينة الأصلية (لا نلمسها)
  required DateTime day,   // أي وقت داخل اليوم
}) {
  // ⚠️ لازم Copy للـ City:
  // الخيار الأفضل إذا عندك toJson/fromJson:
  final City c = City.fromJson(city.toJson());

  // نخليها 12:00 داخل نفس اليوم عشان computePrayerTimes يحسب “ذا اليوم”
  final anchor = DateTime(day.year, day.month, day.day, 12, 0);

  c.computePrayerTimes(anchor);
  _applyRamadanIsha(c, anchor);

  final fajr = c.fajr;
  final dhuhr = c.dhuhr;
  final asr = c.asr;
  final maghrib = c.maghrib;
  final isha = c.isha;

  if (fajr == null || dhuhr == null || asr == null || maghrib == null || isha == null) {
    return null;
  }

  return PrayerTimes(
    fajr: fajr,
    sunrise: c.sunrise,
    dhuhr: dhuhr,
    asr: asr,
    maghrib: maghrib,
    isha: isha,
  );
}
}

class PrayerTimes {
  final DateTime fajr;
  final DateTime? sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  const PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });
}
  /// يرجّع الصلاة القادمة من أوقات City الحالية
  // static ({String key, DateTime time})? nextPrayerKeyTime(City city, DateTime now) {
  //   final fajr = city.fajr;
  //   final sunrise = city.sunrise;
  //   final dhuhr = city.dhuhr;
  //   final asr = city.asr;
  //   final maghrib = city.maghrib;
  //   final isha = city.isha;

  //   if (fajr == null || dhuhr == null || asr == null || maghrib == null || isha == null) {
  //     return null;
  //   }

  //   final items = <({String key, DateTime time})>[
  //     (key: 'fajr', time: fajr),
  //     if (sunrise != null) (key: 'sunrise', time: sunrise),
  //     (key: 'dhuhr', time: dhuhr),
  //     (key: 'asr', time: asr),
  //     (key: 'maghrib', time: maghrib),
  //     (key: 'isha', time: isha),
  //   ];

  //   for (final p in items) {
  //     if (p.time.isAfter(now)) return p;
  //   }

  //   return (key: 'fajr', time: fajr.add(const Duration(days: 1)));
  // }

  /// النص اللي يظهر في الـ UI:
  /// - قبل الأذان: متبقي على أذان...
  /// - بعد الأذان لمدة 30 دقيقة: أذن منذ X دقيقة
  /// - بعد 30 دقيقة: ننتقل للصلاة القادمة
  
  // static const Duration _adhanWindow = Duration(minutes: 30);

// static String? buildTickerText({
//   required City city,
//   required DateTime now,
//   required AppLocalizations l10n,
// }) {
//   // لازم أوقات الصلاة تكون محسوبة مسبقًا في CityProvider عبر:
//   // PrayerService.updateCityPrayerTimes(city: city, now: now);

//   final fajr = city.fajr;
//   final sunrise = city.sunrise;
//   final dhuhr = city.dhuhr;
//   final asr = city.asr;
//   final maghrib = city.maghrib;
//   final isha = city.isha;

//   if (fajr == null || dhuhr == null || asr == null || maghrib == null || isha == null) {
//     return null;
//   }

//   final items = <({String key, DateTime time})>[
//     (key: 'fajr', time: fajr),
//     if (sunrise != null) (key: 'sunrise', time: sunrise),
//     (key: 'dhuhr', time: dhuhr),
//     (key: 'asr', time: asr),
//     (key: 'maghrib', time: maghrib),
//     (key: 'isha', time: isha),
//   ];


//   // next = أول وقت بعد الآن
//   int nextIndex = -1;
//   for (int i = 0; i < items.length; i++) {
//     if (items[i].time.isAfter(now) || now.isBefore(items[i].time.add(_adhanWindow))) {
//       nextIndex = i;
//       final dif = now.difference(items[i].time);
//       final name = nameFor(l10n, items[i].key, now);
//       if (dif > Duration.zero) { //Adhan
//         return "${name} ${l10n.since} : ${fmtRemaining(dif)}";
//         // بعد الوقت: "منذ"
//         // if (items[i].key == 'sunrise') {
//         //   return l10n.sinceEvent(name, fmtRemaining(dif)); // "الشروق منذ 02:10"
//         // }
//         // return l10n.adhanSince(name, fmtRemaining(dif)); // "دخل وقت صلاة ..."

//       } else if (dif < Duration.zero) { //Iqama
//         return "${name} ${l10n.remaining} : ${fmtRemaining(-dif)}";
//         // قبل الوقت: "متبقي"
//         // if (items[i].key == 'sunrise') {
//         //   return l10n.nextEventIn(name, fmtRemaining(-dif)); // "متبقي على الشروق 00:12"
//         // }
//         // return l10n.nextPrayerAdhan(name, fmtRemaining(-dif)); // "متبقي على أذان ..."
//       }
//       break;
//     }
    
//   }

//     // for (final p in items) {
//     //   if (p.time.isBefore(now) && p.time.isAfter(now.subtract(_adhanWindow))) {
//     //     print("Prayer: ${p.key} at ${p.time}");
//     //   }
//     // }

//   // لو ما فيه شيء بعد الآن: يعني بعد العشاء -> next = فجر بكرة
//   if (nextIndex == -1) {
//     final next = (key: 'fajr', time: fajr.add(const Duration(days: 1)));
//     final name = nameFor(l10n, next.key, now);
//     final rem = next.time.difference(now);
//     // return l10n.nextPrayerAdhan(name, fmtRemaining(rem));
//     return "${name}${l10n.remaining}: ${rem}";
//   }

//   // final next = items[nextIndex];
//   // final prev = nextIndex > 0 ? items[nextIndex - 1] : items[items.length - 1];

//   // لو عندنا صلاة سابقة، وداخل نافذة 30 دقيقة بعدها -> "أذن منذ"
//   // if (prev != null) {
//     // final since = now.difference(prev.time);

//     // if (since >= Duration.zero && since < _adhanWindow) {
//     //   final prevName = nameFor(l10n, prev.key, now);
//     //   final mins = since.inMinutes;

//       // لازم تضيفها في l10n:
//       // ar: "أذّن لصلاة {prayer} منذ {minutes} دقيقة"
//       // en: "Adhan for {prayer} was {minutes} min ago"
//       // return l10n.adhanSince(prevName, mins.toString());
//     }
//   // }

//   // // غير كذا: عدّاد للصلاة القادمة
//   // final nextName = nameFor(l10n, next.key, now);
//   // final remaining = next.time.difference(now);
//   // return l10n.nextPrayerAdhan(nextName, fmtRemaining(remaining));
// // }
// }


// import 'package:athkar_new/data/models/city.dart';
// import 'package:athkar_new/gen_l10n/app_localizations.dart';
// import 'package:hijri/hijri_calendar.dart';

// class PrayerService {
//   // =========================
//   // 1) Update city prayer times (used by CityProvider)
//   // =========================
//   static void updateCityPrayerTimes({
//     required City city,
//     required DateTime now,
//   }) {
//     city.computePrayerTimes(now);

//     // ✅ Ramadan: adjust Isha adhan (+30)
//     _applyRamadanIsha(city, now);
//   }

//   // =========================
//   // 2) Ramadan helpers
//   // =========================
//   static bool _isRamadan(DateTime now) {
//     // الأفضل: HijriCalendar.fromDate(now) عشان يكون مرتبط بتاريخ now
//     // (إذا الباكيج ما يدعمها، يرجع للطريقة القديمة)
//     try {
//       final h = HijriCalendar.fromDate(now);
//       return h.hMonth == 9;
//     } catch (_) {
//       final h = HijriCalendar.now();
//       return h.hMonth == 9;
//     }
//   }

//   static void _applyRamadanIsha(City city, DateTime now) {
//     if (!_isRamadan(now)) return;

//     final isha = city.isha;
//     if (isha == null) return;

//     city.isha = isha.add(const Duration(minutes: 30));
//   }

//   // =========================
//   // 3) Iqama delay (normal vs Ramadan)
//   // =========================
//   static Duration? iqamaDelayFor(String key, {required DateTime now}) {
//     final isRamadan = _isRamadan(now);

//     if (key == 'sunrise') return null;

//     if (isRamadan) {
//       // ✅ عدّلها حسب نظامك الحقيقي في رمضان
//       switch (key) {
//         case 'fajr':
//           return const Duration(minutes: 20);
//         case 'maghrib':
//           return const Duration(minutes: 10);
//         case 'isha':
//           return const Duration(minutes: 30);
//         case 'dhuhr':
//         case 'asr':
//           return const Duration(minutes: 20);
//         default:
//           return const Duration(minutes: 20);
//       }
//     }

//     // غير رمضان (نفس اللي كان عندك)
//     switch (key) {
//       case 'fajr':
//         return const Duration(minutes: 25);
//       case 'maghrib':
//         return const Duration(minutes: 15);
//       case 'dhuhr':
//       case 'asr':
//       case 'isha':
//         return const Duration(minutes: 20);
//       case 'sunrise':
//         return null;
//       default:
//         return const Duration(minutes: 20);
//     }
//   }

//   // =========================
//   // 4) Formatting
//   // =========================
//   static String fmtRemaining(Duration d) {
//     if (d.inSeconds <= 0) return "0:00:00";
//     final h = d.inHours;
//     final m = d.inMinutes.remainder(60);
//     final s = d.inSeconds.remainder(60);
//     return "${h}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
//   }

//   // =========================
//   // 5) Localized prayer name (Friday: Dhuhr -> Jumuah)
//   // =========================
//   static String nameFor(AppLocalizations l10n, String key, DateTime now) {
//     if (key == 'dhuhr' && now.weekday == DateTime.friday) {
//       // لازم تضيفها في l10n:
//       // ar: "الجمعة"
//       // en: "Jumu'ah"
//       return l10n.jumuah;
//     }

//     switch (key) {
//       case 'fajr':
//         return l10n.fajr;
//       case 'sunrise':
//         return l10n.sunrise;
//       case 'dhuhr':
//         return l10n.dhuhr;
//       case 'asr':
//         return l10n.asr;
//       case 'maghrib':
//         return l10n.maghrib;
//       case 'isha':
//         return l10n.isha;
//       default:
//         return key;
//     }
//   }

//   /// يرجّع الصلاة القادمة من أوقات City الحالية
//   static ({String key, DateTime time})? nextPrayerKeyTime(City city, DateTime now) {
//     final fajr = city.fajr;
//     final sunrise = city.sunrise;
//     final dhuhr = city.dhuhr;
//     final asr = city.asr;
//     final maghrib = city.maghrib;
//     final isha = city.isha;

//     if (fajr == null || dhuhr == null || asr == null || maghrib == null || isha == null) {
//       return null;
//     }

//     final items = <({String key, DateTime time})>[
//       (key: 'fajr', time: fajr),
//       if (sunrise != null) (key: 'sunrise', time: sunrise),
//       (key: 'dhuhr', time: dhuhr),
//       (key: 'asr', time: asr),
//       (key: 'maghrib', time: maghrib),
//       (key: 'isha', time: isha),
//     ];

//     for (final p in items) {
//       if (p.time.isAfter(now)) return p;
//     }

//     // لو خلصت صلوات اليوم: الفجر حق بكرة
//     return (key: 'fajr', time: fajr.add(const Duration(days: 1)));
//   }

//   /// النص اللي يظهر في الـ UI (الأذان / الإقامة)
//   static String? buildTickerText({
//     required City city,
//     required DateTime now,
//     required AppLocalizations l10n,
//   }) {
//     final next = nextPrayerKeyTime(city, now);
//     if (next == null) return null;

//     final nextName = nameFor(l10n, next.key, now);
//     final remainingToAdhan = next.time.difference(now);
//     // print(  "Next prayer: ${next.key} at ${next.time}, remaining: $remainingToAdhan");

//     // قبل الأذان
//     if (remainingToAdhan.inSeconds >0) {
      
//     // print(  "Next prayer: ${next.key} at ${next.time}, remaining: $remainingToAdhan");
//       return l10n.nextPrayerAdhan(nextName, fmtRemaining(remainingToAdhan));
//     }

//     // بعد الأذان: حاول اعرض الإقامة
//     final delay = iqamaDelayFor(next.key, now: now);
//     if (delay != null) {
//       final iqamaTime = next.time.add(delay);
//       final remainingToIqama = iqamaTime.difference(now);
      
//     // print("iqamaTime: $iqamaTime, remainingToIqama: $remainingToIqama");

//       if (remainingToIqama.inSeconds > 0) {
//         // print("iqamaTime: $iqamaTime, remainingToIqama: $remainingToIqama");
//         return l10n.nextPrayerIqama(nextName, fmtRemaining(remainingToIqama));
        
//       }
//     }

//     // بعد الإقامة: اعرض الصلاة اللي بعدها
//     final after = nextPrayerKeyTime(city, now);
//     if (after == null) return null;

//     final afterName = nameFor(l10n, after.key, now);
//     final rem = after.time.difference(now);
//     return l10n.nextPrayerAdhan(afterName, fmtRemaining(rem));
//   }
// }