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
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get city => 'المدينة';

  @override
  String get resetProgress => 'تصفير تقدّم الأذكار';

  @override
  String get resetDone => 'تم تصفير التقدم ✅';

  @override
  String get morningAthkar => 'أذكار الصباح';

  @override
  String get eveningAthkar => 'أذكار المساء';

  @override
  String get vibrationOn => 'مفعّل';

  @override
  String get vibrationOff => 'مطفّي';
}
