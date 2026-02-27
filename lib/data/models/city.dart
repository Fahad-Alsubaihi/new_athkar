import 'dart:math';
import 'package:intl/intl.dart';
import 'package:adhan/adhan.dart';

class City {
  final Map<String, String> name;
  final double latitude;
  final double longitude;

  // (قديم) شروق/غروب - خله إذا تبغاه لعرضه فقط
  DateTime? sunrise;
  DateTime? sunset;

  // ✅ جديد: أوقات الصلاة
  DateTime? fajr;
  DateTime? dhuhr;
  DateTime? asr;
  DateTime? maghrib;
  DateTime? isha;

  City({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: Map<String, String>.from(json['name']),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
      };

  // -----------------------------
  // (اختياري) Sunrise / Sunset
  // -----------------------------
  // int _dayOfYear(DateTime date) => int.parse(DateFormat("D").format(date));
  // double _degToRad(double deg) => deg * pi / 180;

  // DateTime _calculateSun({
  //   required bool isSunrise,
  //   required DateTime date,
  // }) {
  //   int day = _dayOfYear(date);
  //   const double zenith = 90.833;

  //   double latRad = _degToRad(latitude);
  //   double decl = 0.4095 * sin(_degToRad(360 / 365 * (day - 81)));

  //   double cosH = (cos(_degToRad(zenith)) - sin(latRad) * sin(decl)) /
  //       (cos(latRad) * cos(decl));

  //   if (cosH > 1) throw Exception("no_sunrise");
  //   if (cosH < -1) throw Exception("no_sunset");

  //   double hourAngle = acos(cosH) * 180 / pi;

  //   double timeInHours = isSunrise
  //       ? (720 - 4 * (longitude + hourAngle)) / 60
  //       : (720 - 4 * (longitude - hourAngle)) / 60;

  //   double utcOffset = date.timeZoneOffset.inMinutes / 60.0;
  //   timeInHours += utcOffset;

  //   int hours = timeInHours.floor();
  //   int minutes = ((timeInHours - hours) * 60).round();

  //   return DateTime(date.year, date.month, date.day, hours, minutes);
  // }

  // void computeSunTimes(DateTime date) {
  //   try {
  //     sunrise = _calculateSun(isSunrise: true, date: date);
  //     sunset = _calculateSun(isSunrise: false, date: date);
  //   } catch (_) {
  //     sunrise = DateTime(date.year, date.month, date.day, 6, 0);
  //     sunset = DateTime(date.year, date.month, date.day, 18, 0);
  //   }
  // }

  // -----------------------------
  // ✅ Prayer Times (adhan)
  // -----------------------------
  void computePrayerTimes(DateTime date) {
    final coords = Coordinates(latitude, longitude);

    // ✅ أسماء الطريقة الصحيحة في adhan:
    final params = CalculationMethod.umm_al_qura.getParameters();
    // إذا تبي: params.madhab = Madhab.hanafi; (اختياري)
    params.madhab = Madhab.shafi;
    // params.madhab = Madhab.hanafi;

    final pt = PrayerTimes(coords, DateComponents.from(date), params);

    fajr = pt.fajr;
    sunrise = pt.sunrise; // تقدر تخزنها هنا بدل حساب الشمس
    dhuhr = pt.dhuhr;
    asr = pt.asr;
    maghrib = pt.maghrib;
    isha = pt.isha;
    sunset = pt.maghrib; // لو تبي تعتبر المغرب = غروب
  }
}
