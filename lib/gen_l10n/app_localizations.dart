import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'My Athkar'**
  String get appName;

  /// No description provided for @benifit.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get benifit;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @defaultSettings.
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get defaultSettings;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get fontSize;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @resetProgress.
  ///
  /// In en, this message translates to:
  /// **'Reset Athkar Progress'**
  String get resetProgress;

  /// No description provided for @resetDone.
  ///
  /// In en, this message translates to:
  /// **'Settings restored successfully'**
  String get resetDone;

  /// No description provided for @morningAthkar.
  ///
  /// In en, this message translates to:
  /// **'Morning Athkar'**
  String get morningAthkar;

  /// No description provided for @eveningAthkar.
  ///
  /// In en, this message translates to:
  /// **'Evening Athkar'**
  String get eveningAthkar;

  /// No description provided for @vibrationOn.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get vibrationOn;

  /// No description provided for @vibrationOff.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get vibrationOff;

  /// No description provided for @vibrationMode.
  ///
  /// In en, this message translates to:
  /// **'Counter Vibration'**
  String get vibrationMode;

  /// No description provided for @vibrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vibrates with each count during athkar'**
  String get vibrationSubtitle;

  /// No description provided for @fajr.
  ///
  /// In en, this message translates to:
  /// **'fajr'**
  String get fajr;

  /// No description provided for @sunrise.
  ///
  /// In en, this message translates to:
  /// **'sunrise'**
  String get sunrise;

  /// No description provided for @dhuhr.
  ///
  /// In en, this message translates to:
  /// **'dhuhr'**
  String get dhuhr;

  /// No description provided for @asr.
  ///
  /// In en, this message translates to:
  /// **'asr'**
  String get asr;

  /// No description provided for @maghrib.
  ///
  /// In en, this message translates to:
  /// **'maghrib'**
  String get maghrib;

  /// No description provided for @isha.
  ///
  /// In en, this message translates to:
  /// **'isha'**
  String get isha;

  /// No description provided for @jumuah.
  ///
  /// In en, this message translates to:
  /// **'jumuah'**
  String get jumuah;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get remaining;

  /// No description provided for @since.
  ///
  /// In en, this message translates to:
  /// **'since'**
  String get since;

  /// No description provided for @prayerReminderNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Time'**
  String get prayerReminderNotifTitle;

  /// No description provided for @prayerReminderBody.
  ///
  /// In en, this message translates to:
  /// **'It is now time for {prayer}'**
  String prayerReminderBody(Object prayer);

  /// No description provided for @athkarReminderNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Athkar'**
  String get athkarReminderNotifTitle;

  /// No description provided for @athkarMorningReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Time for Morning Athkar'**
  String get athkarMorningReminderBody;

  /// No description provided for @athkarEveningReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Time for Evening Athkar'**
  String get athkarEveningReminderBody;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @prayerReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer reminders'**
  String get prayerReminderTitle;

  /// No description provided for @prayerReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notify at each prayer time'**
  String get prayerReminderSubtitle;

  /// No description provided for @athkarReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Athkar reminders'**
  String get athkarReminderTitle;

  /// No description provided for @athkarReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'1 hour after Fajr and Asr'**
  String get athkarReminderSubtitle;

  /// No description provided for @remindersNote.
  ///
  /// In en, this message translates to:
  /// **'You may need to allow notifications in system settings.'**
  String get remindersNote;

  /// No description provided for @useMyCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my current location'**
  String get useMyCurrentLocation;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enable location services and grant location permission.'**
  String get locationPermissionRequired;

  /// No description provided for @notificationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enable notifications to allow the app to send alerts'**
  String get notificationPermissionRequired;

  /// No description provided for @locationUpdating.
  ///
  /// In en, this message translates to:
  /// **'Getting your location…'**
  String get locationUpdating;

  /// No description provided for @locationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Location updated'**
  String get locationUpdated;

  /// No description provided for @locationUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t get your location.'**
  String get locationUpdateFailed;

  /// No description provided for @myCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'My current location'**
  String get myCurrentLocation;

  /// No description provided for @lastLocationUpdate.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get lastLocationUpdate;

  /// No description provided for @nextPrayerAdhan.
  ///
  /// In en, this message translates to:
  /// **'{prayer} Adhan in {time}'**
  String nextPrayerAdhan(Object prayer, Object time);

  /// No description provided for @adhanSince.
  ///
  /// In en, this message translates to:
  /// **'Adhan for {prayer} was {minutes} min ago'**
  String adhanSince(Object prayer, Object minutes);

  /// No description provided for @remainingH.
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get remainingH;

  /// No description provided for @remainingM.
  ///
  /// In en, this message translates to:
  /// **'minute'**
  String get remainingM;

  /// No description provided for @calculationMethod.
  ///
  /// In en, this message translates to:
  /// **'According to the Umm al-Qura calendar'**
  String get calculationMethod;

  /// No description provided for @nextPrayerIqama.
  ///
  /// In en, this message translates to:
  /// **'{prayer} Iqama in {time}'**
  String nextPrayerIqama(Object prayer, Object time);

  /// No description provided for @nextEventIn.
  ///
  /// In en, this message translates to:
  /// **'{event} in {time}'**
  String nextEventIn(Object event, Object time);

  /// No description provided for @sinceEvent.
  ///
  /// In en, this message translates to:
  /// **'{event} since {time}'**
  String sinceEvent(Object event, Object time);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
