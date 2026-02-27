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
  String get benifit => 'Source';

  @override
  String get settings => 'Settings';

  @override
  String get defaultSettings => 'Reset to Default';

  @override
  String get fontSize => 'Font size';

  @override
  String get language => 'Language';

  @override
  String get city => 'City';

  @override
  String get resetProgress => 'Reset Athkar Progress';

  @override
  String get resetDone => 'Settings restored successfully';

  @override
  String get morningAthkar => 'Morning Athkar';

  @override
  String get eveningAthkar => 'Evening Athkar';

  @override
  String get vibrationOn => 'Enabled';

  @override
  String get vibrationOff => 'Disabled';

  @override
  String get vibrationMode => 'Counter Vibration';

  @override
  String get vibrationSubtitle => 'Vibrates with each count during athkar';

  @override
  String get fajr => 'fajr';

  @override
  String get sunrise => 'sunrise';

  @override
  String get dhuhr => 'dhuhr';

  @override
  String get asr => 'asr';

  @override
  String get maghrib => 'maghrib';

  @override
  String get isha => 'isha';

  @override
  String get jumuah => 'jumuah';

  @override
  String get remaining => 'remaining';

  @override
  String get since => 'since';

  @override
  String get prayerReminderNotifTitle => 'Prayer Time';

  @override
  String prayerReminderBody(Object prayer) {
    return 'It is now time for $prayer';
  }

  @override
  String get athkarReminderNotifTitle => 'Athkar';

  @override
  String get athkarMorningReminderBody => 'Time for Morning Athkar';

  @override
  String get athkarEveningReminderBody => 'Time for Evening Athkar';

  @override
  String get reminders => 'Reminders';

  @override
  String get prayerReminderTitle => 'Prayer reminders';

  @override
  String get prayerReminderSubtitle => 'Notify at each prayer time';

  @override
  String get athkarReminderTitle => 'Athkar reminders';

  @override
  String get athkarReminderSubtitle => '1 hour after Fajr and Asr';

  @override
  String get remindersNote =>
      'You may need to allow notifications in system settings.';

  @override
  String get useMyCurrentLocation => 'Use my current location';

  @override
  String get locationPermissionRequired =>
      'Please enable location services and grant location permission.';

  @override
  String get notificationPermissionRequired =>
      'Please enable notifications to allow the app to send alerts';

  @override
  String get locationUpdating => 'Getting your location…';

  @override
  String get locationUpdated => 'Location updated';

  @override
  String get locationUpdateFailed => 'Couldn\'t get your location.';

  @override
  String get myCurrentLocation => 'My current location';

  @override
  String get lastLocationUpdate => 'Last updated';

  @override
  String nextPrayerAdhan(Object prayer, Object time) {
    return '$prayer Adhan in $time';
  }

  @override
  String adhanSince(Object prayer, Object minutes) {
    return 'Adhan for $prayer was $minutes min ago';
  }

  @override
  String get remainingH => 'hour';

  @override
  String get remainingM => 'minute';

  @override
  String get calculationMethod => 'According to the Umm al-Qura calendar';

  @override
  String nextPrayerIqama(Object prayer, Object time) {
    return '$prayer Iqama in $time';
  }

  @override
  String nextEventIn(Object event, Object time) {
    return '$event in $time';
  }

  @override
  String sinceEvent(Object event, Object time) {
    return '$event since $time';
  }
}
