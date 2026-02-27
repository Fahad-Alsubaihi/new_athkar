class AppConstants {
  AppConstants._();

  // =========================
  // App
  // =========================

  static const String appName = "Athkar";

  // =========================
  // Storage Keys
  // =========================

  static const String progressKey = "progress_v3";

  static const String selectedCityKey = "selected_city_key_v1";

  static const String languageKey = "languageCode";

  static const String vibrationKey = "vibration";

  static const String fontScaleKey = "fontScale";

  static const String prayerReminderKey = "prayer_reminder_v1";

  static const String athkarReminderKey = "athkar_reminder_v1";

  static const String scheduledPrayerIdsKey = "scheduled_prayer_ids_v1";

  static const String scheduledAthkarIdsKey = "scheduled_athkar_ids_v1";

  static const String lastScheduleYmdKey = "last_schedule_ymd_v1";

  // =========================
  // Assets
  // =========================

  static const String citiesJson = "assets/data/cities.json";

  static const String morningJson = "assets/data/ARmorning.json";

  static const String eveningJson = "assets/data/ARnight.json";

  // =========================
  // UI
  // =========================

  static const String fontFamily = "Baloo";
  

    // =========================
  // Location (Current Location City)
  // =========================
  static const String currentLocationLatKey = "current_location_lat_v1";
  static const String currentLocationLngKey = "current_location_lng_v1";
  static const String currentLocationLabelKey = "current_location_label_v1";
  static const String currentLocationUpdatedAtMsKey =
      "current_location_updated_ms_v1";

}
