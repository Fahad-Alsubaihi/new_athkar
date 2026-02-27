// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'أذكاري';

  @override
  String get benifit => 'المصدر';

  @override
  String get settings => 'الإعدادات';

  @override
  String get defaultSettings => 'استعادة الإعدادات الإفتراضية';

  @override
  String get fontSize => 'حجم الخط';

  @override
  String get language => 'اللغة';

  @override
  String get city => 'المدينة';

  @override
  String get resetProgress => 'تصفير تقدّم الأذكار';

  @override
  String get resetDone => 'تم إعادة ضبط الإعدادات الافتراضية';

  @override
  String get morningAthkar => 'أذكار الصباح';

  @override
  String get eveningAthkar => 'أذكار المساء';

  @override
  String get vibrationOn => 'مفعّل';

  @override
  String get vibrationOff => 'مطفّي';

  @override
  String get vibrationMode => 'اهتزاز عدّاد الأذكار';

  @override
  String get vibrationSubtitle => 'يهتز مع كل عدّة أثناء الذكر';

  @override
  String get fajr => 'الفجر';

  @override
  String get sunrise => 'الشروق';

  @override
  String get dhuhr => 'الظهر';

  @override
  String get asr => 'العصر';

  @override
  String get maghrib => 'المغرب';

  @override
  String get isha => 'العشاء';

  @override
  String get jumuah => 'الجمعة';

  @override
  String get remaining => 'متبقي';

  @override
  String get since => 'منذ';

  @override
  String get prayerReminderNotifTitle => 'وقت الصلاة';

  @override
  String prayerReminderBody(Object prayer) {
    return 'دخل الآن وقت صلاة $prayer';
  }

  @override
  String get athkarReminderNotifTitle => 'الأذكار';

  @override
  String get athkarMorningReminderBody => 'حان وقت أذكار الصباح';

  @override
  String get athkarEveningReminderBody => 'حان وقت أذكار المساء';

  @override
  String get reminders => 'التنبيهات';

  @override
  String get prayerReminderTitle => 'تذكير الصلاة';

  @override
  String get prayerReminderSubtitle => 'تنبيه عند كل صلاة';

  @override
  String get athkarReminderTitle => 'تذكير الأذكار';

  @override
  String get athkarReminderSubtitle => 'بعد أذان الفجر والعصر بساعة';

  @override
  String get remindersNote => 'قد تحتاج السماح بالإشعارات من إعدادات الجهاز.';

  @override
  String get useMyCurrentLocation => 'استخدم موقعي الحالي';

  @override
  String get locationPermissionRequired =>
      'فضلاً فعّل خدمات الموقع واسمح للتطبيق بالوصول للموقع';

  @override
  String get notificationPermissionRequired =>
      'فضلاً فعّل الإشعارات للسماح للتطبيق بإرسال التنبيهات';

  @override
  String get locationUpdating => 'جاري تحديد الموقع…';

  @override
  String get locationUpdated => 'تم تحديث الموقع';

  @override
  String get locationUpdateFailed => 'تعذر تحديد الموقع.';

  @override
  String get myCurrentLocation => 'موقعي الحالي';

  @override
  String get lastLocationUpdate => 'آخر تحديث';

  @override
  String nextPrayerAdhan(Object prayer, Object time) {
    return 'متبقي على أذان $prayer $time';
  }

  @override
  String adhanSince(Object prayer, Object minutes) {
    return 'أذّن لصلاة $prayer منذ $minutes دقيقة';
  }

  @override
  String get remainingH => 'ساعة';

  @override
  String get remainingM => 'دقيقة';

  @override
  String get calculationMethod => 'حسب تقويم أم القرى';

  @override
  String nextPrayerIqama(Object prayer, Object time) {
    return 'متبقي على إقامة $prayer $time';
  }

  @override
  String nextEventIn(Object event, Object time) {
    return 'متبقي على $event $time';
  }

  @override
  String sinceEvent(Object event, Object time) {
    return '$event منذ $time';
  }
}
