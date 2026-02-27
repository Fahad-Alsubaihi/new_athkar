import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String channelPrayers = 'prayers';
  static const String channelAthkar = 'athkar';

  static bool _inited = false;
  static bool _tzInited = false;

  static Future<void> _initTimezone() async {
    if (_tzInited) return;

    tzdata.initializeTimeZones();

    // flutter_timezone يرجّع TimezoneInfo
    final TimezoneInfo tzName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzName.identifier));

    _tzInited = true;

    if (kDebugMode) {
      print('TZ local = ${tz.local.name}');
    }
  }

  static Future<void> init() async {
    if (_inited) return;

    await _initTimezone();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );

    await _plugin.initialize(settings: initSettings);

    const prayersChannel = AndroidNotificationChannel(
      channelPrayers,
      'Prayer reminders',
      description: 'Notifications for prayer times',
      importance: Importance.max,
    );

    const athkarChannel = AndroidNotificationChannel(
      channelAthkar,
      'Athkar reminders',
      description: 'Notifications for morning/evening athkar',
      importance: Importance.high,
    );

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(prayersChannel);
    await android?.createNotificationChannel(athkarChannel);

    _inited = true;
  }

  /// طلب إذن الإشعارات + التحقق أنه مفعّل فعليًا
  /// يرجّع true إذا المستخدم وافق (أو الإذن موجود من قبل)
  /// ويرجّع false إذا رفض/الإشعارات مقفلة من إعدادات النظام (خصوصًا Android)
  static Future<bool> requestPermissionIfNeeded() async {
    await init();

    // iOS
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final bool iosOk = await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: false,
        ) ??
        true;

    // macOS
    final macos = _plugin.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();
    final bool macOk = await macos?.requestPermissions(
          alert: true,
          badge: true,
          sound: false,
        ) ??
        true;

    // Android 13+
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    // تحقق هل الإشعارات مفعلة فعليًا (إذا الدالة مدعومة)
      bool androidEnabled = true;

      try {
        final result = await android?.areNotificationsEnabled();
        androidEnabled = result ?? true;
      } catch (_) {
        androidEnabled = true;
      }

    return iosOk && macOk && androidEnabled;
  }

  static NotificationDetails detailsFor(String channelId) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelId == channelPrayers ? 'Prayer reminders' : 'Athkar reminders',
        channelDescription: channelId == channelPrayers
            ? 'Notifications for prayer times'
            : 'Notifications for morning/evening athkar',
        importance: Importance.max,
        priority: Priority.max,
        // لا نستخدم alarm كتصنيف افتراضي عشان ما نشدّد على الأجهزة
        category: AndroidNotificationCategory.reminder,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: false,
        presentBadge: true,
      ),
    );
  }

  static Future<void> cancel(int id) => _plugin.cancel(id: id);

  // static Future<void> cancelRange(int fromId, int toId) async {
  //   for (int i = fromId; i <= toId; i++) {
  //     await _plugin.cancel(id: i);
  //   }
  // }

  /// جدولة “واحدة” مع اختيار وضع الجدولة
  static Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime when,
    required String channelId,
    required AndroidScheduleMode mode,
  }) async {
    await init();

    final ok = await requestPermissionIfNeeded();
    if (!ok) return;

    if (!when.isAfter(DateTime.now())) return;

    final tzWhen = tz.TZDateTime.from(when, tz.local);

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzWhen,
      notificationDetails: detailsFor(channelId),
      androidScheduleMode: mode,
      matchDateTimeComponents: null,
      // iOS: تفسير الوقت كوقت مطلق (أفضل مع tz)
   
    );

    if (kDebugMode) {
      print('Scheduled id=$id mode=$mode at $when');
    }
  }

  /// جدولة قائمة إشعارات “بذكاء” عشان البطارية:
  /// - أقرب إشعار فقط exact (إذا مسموح)
  /// - الباقي inexact
  static Future<void> scheduleBatchSmart({
    required List<PendingNotification> items,
  }) async {
    await init();

    final ok = await requestPermissionIfNeeded();
    if (!ok) return;

    final now = DateTime.now();
    final upcoming = items.where((x) => x.when.isAfter(now)).toList()
      ..sort((a, b) => a.when.compareTo(b.when));

    if (upcoming.isEmpty) return;

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    var canExact = await android?.canScheduleExactNotifications() ?? false;

    // إذا ما يقدر exact، حاول تطلبها مرة (بدون ما نوقف الدنيا)
    if (!canExact) {
      await android?.requestExactAlarmsPermission();
      await Future.delayed(const Duration(milliseconds: 300));
      canExact = await android?.canScheduleExactNotifications() ?? false;
    }

    for (int i = 0; i < upcoming.length; i++) {
      final p = upcoming[i];
      final mode = (i == 0 && canExact)
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;

      await schedule(
        id: p.id,
        title: p.title,
        body: p.body,
        when: p.when,
        channelId: p.channelId,
        mode: mode,
      );
    }
  }

  // تيست
  static Future<void> testIn10Seconds() async {
    await init();

    final ok = await requestPermissionIfNeeded();
    if (!ok) return;

    final when = DateTime.now().add(const Duration(seconds: 10));
    await scheduleBatchSmart(
      items: [
        PendingNotification(
          id: 9999,
          title: 'اختبار بعد 10 ثواني',
          body: 'إذا وصلك هذا فالإشعارات شغالة ✅',
          when: when,
          channelId: channelAthkar,
        ),
      ],
    );
  }

  static Future<void> showNowTest() async {
    await init();

    final ok = await requestPermissionIfNeeded();
    if (!ok) return;

    await _plugin.show(
      id: 7777,
      title: 'اختبار الآن',
      body: 'إذا ما وصل هذا، المشكلة إذن/قناة/إعدادات نظام',
      notificationDetails: detailsFor(channelAthkar),
    );
  }
}

/// عنصر جدولة
class PendingNotification {
  final int id;
  final String title;
  final String body;
  final DateTime when;
  final String channelId;

  PendingNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.when,
    required this.channelId,
  });
}