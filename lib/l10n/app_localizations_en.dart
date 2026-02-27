// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'My Athkar';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get city => 'City';

  @override
  String get resetProgress => 'Reset Athkar Progress';

  @override
  String get resetDone => 'Progress reset successfully ✅';

  @override
  String get morningAthkar => 'Morning Athkar';

  @override
  String get eveningAthkar => 'Evening Athkar';

  @override
  String get vibrationOn => 'Enabled';

  @override
  String get vibrationOff => 'Disabled';
}
