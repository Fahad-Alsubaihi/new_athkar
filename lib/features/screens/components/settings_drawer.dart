import 'dart:ui';
import 'package:athkar_new/services/notification_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/reminder_scheduler.dart';

import 'package:athkar_new/gen_l10n/app_localizations.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../../../providers/settings_provider.dart';
import '../../../data/models/city.dart';
import '../../../data/models/cities.dart';

import '../../../services/prayer_service.dart';

class SettingsDrawer extends StatelessWidget {
  final Future<void> Function()? onResetProgress;

  const SettingsDrawer({
    Key? key,
    this.onResetProgress,
  }) : super(key: key);

  String _weekdayName(BuildContext context, DateTime date) {
    final lang = Localizations.localeOf(context).languageCode;
    return DateFormat.EEEE(lang).format(date); // مثال: Friday / الجمعة
  }

  String _hijriToday(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    HijriCalendar.setLocal(lang);

    final h = HijriCalendar.now();
    final monthName = h.getLongMonthName();
    return "${h.hDay} $monthName ${h.hYear}";
  }

  String _gregorianToday(BuildContext context, DateTime now) {
    final lang = Localizations.localeOf(context).languageCode;
    // final now = DateTime.now();
    return "${now.day} ${DateFormat.MMMM(lang).format(now)} ${now.year}";
  }

  String _fmtTime(BuildContext context, DateTime? t) {
    if (t == null) return '--';

    final lang = Localizations.localeOf(context).languageCode;
    final formatted = DateFormat('h:mm a', 'en').format(t);

    if (lang == 'ar') {
      return formatted.replaceAll('AM', 'ص').replaceAll('PM', 'م');
    }
    return formatted;
  }

String _fmtLastUpdateTime(DateTime dt, {required bool isArabic}) {
  final formatted =
      DateFormat('yyyy/MM/dd • h:mm a', 'en').format(dt);

  if (!isArabic) return formatted;

  return formatted
      .replaceAll(RegExp(r'AM', caseSensitive: false), 'ص')
      .replaceAll(RegExp(r'PM', caseSensitive: false), 'م');
}

void _showMiniMessage(BuildContext context, String message,
    {Duration duration = const Duration(seconds: 2)}) {
  final overlay = Overlay.of(context);

  final entry = OverlayEntry(
    builder: (_) => Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);

  Future.delayed(duration, () => entry.remove());
}

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();
    final cityProvider = context.watch<CityProvider>();

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    final lang = Localizations.localeOf(context).languageCode;
    final isArabic = lang == 'ar';

    final drawerBg = cs.surface.withOpacity(0.75);

    final now = DateTime.now();

    final divider = Theme.of(context).dividerColor;

    final city = cityProvider.selectedCity ??
        (cityProvider.cities.isNotEmpty ? cityProvider.cities.first : null);

    final cityName = city == null
        ? '—'
        : (isArabic
            ? (city.name['ar'] ?? city.name['en'] ?? '')
            : (city.name['en'] ?? city.name['ar'] ?? ''));

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Drawer(
          backgroundColor: drawerBg,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =====================
                // Header ثابت
                // =====================
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        l10n.settings,
                        style:
                            tt.headlineSmall?.copyWith(fontFamily: 'Baloo'),
                      ),
                      Divider(color: divider),
                    ],
                  ),
                ),

                // =====================
                // Body (سكرول)
                // =====================
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ======= Hijri + Prayer times =======
                        Card(
                          color: const Color.fromARGB(0, 208, 208, 208),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                      Text(" $cityName", style: tt.titleLarge),
//                                   ],
//                                 ),
//                                 // Divider(color: divider),
// const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        //  const SizedBox(height: 4),
                                        Text(
                                          "${_weekdayName(context, now)}",
                                          style: tt.bodyMedium,
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(" ${_hijriToday(context)}",
                                            style: tt.bodyMedium),
                                        const SizedBox(height: 4),
                                        Text(" ${_gregorianToday(context, now)}",
                                            style: tt.bodyMedium),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Divider(color: divider),

                                // if (city == null || city.fajr == null)
                                // Text(l10n.city, style: tt.bodyMedium),
                                // else ...
                                // [
                                StreamBuilder<int>(
                                  initialData: 0,
                                  stream: Stream.periodic(
                                      const Duration(seconds: 1), (i) => i),
                                  builder: (context, snapshot) {
                                    final now = DateTime.now();

                                    final ticker = PrayerService.buildTicker(
                                      city: city!,
                                      now: now,
                                      l10n: l10n,
                                    );

                                    final activeKey = ticker?.activeKey;

                                    return Column(
                                      children: [
                                        if (ticker != null)
                                          Text(
                                            ticker.text,
                                            style: tt.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: cs.primary,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        const SizedBox(height: 6),
                                        Divider(color: divider),
                                        const SizedBox(height: 8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            _AzanRow(
                                              title: PrayerService.nameFor(
                                                  l10n, 'fajr', now),
                                              value: _fmtTime(context, city.fajr),
                                              icon: CupertinoIcons.moon_stars,
                                              isActive: activeKey == 'fajr',
                                            ),
                                            _AzanRow(
                                              title: PrayerService.nameFor(
                                                  l10n, 'sunrise', now),
                                              value: _fmtTime(
                                                  context, city.sunrise),
                                              icon: CupertinoIcons.sunrise,
                                              isActive: activeKey == 'sunrise',
                                            ),
                                            _AzanRow(
                                              title: PrayerService.nameFor(
                                                  l10n, 'dhuhr', now),
                                              value: _fmtTime(
                                                  context, city.dhuhr),
                                              icon: CupertinoIcons.sun_max,
                                              isActive: activeKey == 'dhuhr',
                                            ),
                                            _AzanRow(
                                              title: PrayerService.nameFor(
                                                  l10n, 'asr', now),
                                              value: _fmtTime(context, city.asr),
                                              icon: CupertinoIcons.sun_min,
                                              isActive: activeKey == 'asr',
                                            ),
                                            _AzanRow(
                                              title: PrayerService.nameFor(
                                                  l10n, 'maghrib', now),
                                              value: _fmtTime(
                                                  context, city.maghrib),
                                              icon: CupertinoIcons.sunset,
                                              isActive: activeKey == 'maghrib',
                                            ),
                                            _AzanRow(
                                              title: PrayerService.nameFor(
                                                  l10n, 'isha', now),
                                              value: _fmtTime(context, city.isha),
                                              icon: CupertinoIcons.moon,
                                              isActive: activeKey == 'isha',
                                            ),
                                            Text(
                                              "${l10n.calculationMethod}",
                                              style: tt.labelMedium,
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 6),
                                Divider(color: divider),
                              ],
                              // ],
                            ),
                          ),
                        ),

                        // Divider(color: divider),
                        const SizedBox(height: 16),

                        // ======= City Dropdown =======
                        if (cityProvider.cities.isEmpty)
                          Text('...', style: tt.bodyMedium)
                        else
                          DropdownButtonFormField<City>(
                            value: cityProvider.selectedCity ??
                                cityProvider.cities.first,
                            decoration: InputDecoration(labelText: l10n.city),
                            dropdownColor: cs.surface,
                            items: cityProvider.cities.map((c) {
                              final name = isArabic
                                  ? (c.name['ar'] ?? c.name['en'] ?? '')
                                  : (c.name['en'] ?? c.name['ar'] ?? '');
                              return DropdownMenuItem<City>(
                                value: c,
                                child: Text(name),
                              );
                            }).toList(),
                            onChanged: (City? c) async {
                              if (c == null) return;
                              await cityProvider.selectCity(c);

                              // ReminderScheduler.queueReschedule(
                              //   city: c!,
                              //   prayersEnabled: settings.prayerReminder,
                              //   athkarEnabled: settings.athkarReminder,
                              //   l10n: l10n,
                               // // daysAhead: 2,
                              //  // debounce: const Duration(seconds: 1),
                              // );


                              //  if (selected != null) {
                              // await ReminderScheduler.reschedule(
                              //   city: c,
                              //   prayersEnabled: settings.prayerReminder,
                              //   athkarEnabled: settings.athkarReminder,
                              //   l10n: l10n,
                              //   daysAhead: 2, // ✅
                              // );
                              // }
                            },
                          ),
                        // const SizedBox(height: 12),

                        Column(
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.my_location),
                              label: Text(l10n.useMyCurrentLocation),
                                                  onPressed: () async {
                                _showMiniMessage(context, l10n.locationUpdating, duration: const Duration(seconds: 1));
                            
                                final ok = await context.read<CityProvider>().selectCurrentLocation(
                                  prayersEnabled: settings.prayerReminder,
                                  athkarEnabled: settings.athkarReminder,
                                  l10n: l10n,
                                );
                            
                                if (!context.mounted) return;
                            
                                if (ok) {
                                  await settings.setLastLocationUpdate(DateTime.now()); // ✅ هنا نعطيه قيمة
                                }
                            
                                _showMiniMessage(
                                  context,
                                  ok ? l10n.locationUpdated : l10n.locationUpdateFailed,
                                  duration: const Duration(seconds: 2),
                                );
                              },
                            ),

                                                    // const SizedBox(height: 6),

                        if (settings.lastLocationUpdate != null) ...[
                              // const SizedBox(height: 6),
                              Text(
                                "${l10n.lastLocationUpdate} • ${_fmtLastUpdateTime(
                                  settings.lastLocationUpdate!,
                                  isArabic: isArabic,
                                )}",
                                style: tt.bodySmall?.copyWith(
                                  color: tt.bodySmall?.color?.withOpacity(0.7),
                                ),
                              ),
],

                          ],
                        ),

const SizedBox(height: 16),

                        // // ======= Language (commented) =======
                        // DropdownButtonFormField<String>(
                        //   value: settings.languageCode,
                        //   decoration: InputDecoration(labelText: l10n.language),
                        //   dropdownColor: cs.surface,
                        //   items: const [
                        //     DropdownMenuItem(value: 'ar', child: Text('العربية')),
                        //     DropdownMenuItem(value: 'en', child: Text('English')),
                        //   ],
                        //   onChanged: (String? code) async {
                        //     if (code == null) return;
                        //     await settings.setLanguage(code);
                        //   },
                        // ),


                        // ======= Reminders =======
                        Card(
                          color: const Color.fromARGB(0, 208, 208, 208),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(CupertinoIcons.bell,
                                        size: 18, color: cs.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.reminders, // إذا ما عندكها، خلها Text('التذكيرات')
                                      style: tt.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Divider(color: divider),

                                const SizedBox(height: 12),

                                // Row(
                                //   children: [
                                //     Expanded(
                                //       child: ElevatedButton(
                                //         onPressed: () async {
                                //           await NotificationService.showNow(
                                //             id: 7777,
                                //             title: 'اختبار فوري',
                                //             body: 'إذا شفت هذا فالإشعارات شغالة ✅',
                                //             channelId: NotificationService.channelAthkar,
                                //           );
                                //         },
                                //         child: const Text('اختبار فوري'),
                                //       ),
                                //     ),
                                //     const SizedBox(width: 8),
                                //     Expanded(
                                //       child: ElevatedButton(
                                //         onPressed: () async {
                                //           await NotificationService.testIn10Seconds();
                                //         },
                                //         child: const Text('اختبار 10 ثواني'),
                                //       ),
                                //     ),
                                //   ],
                                // ),

                                // تذكير الصلاة
                                _IosSwitchRow(
                                  icon: CupertinoIcons.time,
                                  title: l10n.prayerReminderTitle, // أو "تذكير الصلاة"
                                  subtitle: l10n.prayerReminderSubtitle, // أو "عند كل صلاة"
                                  value: settings.prayerReminder,
                                  onChanged: (v) async {
                                      // إذا بيطفي: طفّه مباشرة ثم أعد الجدولة
                                      if (!v) {
                                        await settings.setPrayerReminder(false);

                                        final selected = cityProvider.selectedCity ??
                                            (cityProvider.cities.isNotEmpty ? cityProvider.cities.first : null);

                                        if (selected != null) {
                                          ReminderScheduler.queueReschedule(
                                            city: selected,
                                            prayersEnabled: settings.prayerReminder,
                                            athkarEnabled: false,
                                            l10n: l10n,
                                          );
                                        }
                                        return;
                                      }

                                      // إذا بيشغل: اطلب الإذن أول
                                      final ok = await NotificationService.requestPermissionIfNeeded();
                                      if (!ok) {
                                        // المستخدم رفض/الإشعارات مقفلة من النظام -> لا تغيّر الإعداد
                                        // (السويتش بيظل OFF لأن value مربوط بـ settings.athkarReminder)
                                           _showMiniMessage(
                                            context,
                                            l10n.notificationPermissionRequired, // أو "يرجى السماح بالإشعارات لتفعيل هذا الخيار" ,
                                            duration: const Duration(seconds: 2),
                                          );
                                        return;
                                      }

                                      // الإذن موجود -> فعّل ثم أعد الجدولة
                                      await settings.setPrayerReminder(true);

                                      final selected = cityProvider.selectedCity ??
                                          (cityProvider.cities.isNotEmpty ? cityProvider.cities.first : null);

                                      if (selected != null) {
                                        ReminderScheduler.queueReschedule(
                                          city: selected,
                                          prayersEnabled: settings.prayerReminder,
                                          athkarEnabled: false,
                                          l10n: l10n,
                                        );
                                      }
                                    },
                                ),

                                const SizedBox(height: 6),

                                // تذكير الأذكار
                                _IosSwitchRow(
                                  icon: CupertinoIcons.moon_stars,
                                  title: l10n.athkarReminderTitle, // أو "تذكير الأذكار"
                                  subtitle: l10n.athkarReminderSubtitle, // أو "بعد الفجر والعصر بساعة"
                                  value: settings.athkarReminder,
                                 onChanged: (v) async {
                                    // إذا بيطفي: طفّه مباشرة ثم أعد الجدولة
                                    if (!v) {
                                      await settings.setAthkarReminder(false);

                                      final selected = cityProvider.selectedCity ??
                                          (cityProvider.cities.isNotEmpty ? cityProvider.cities.first : null);

                                      if (selected != null) {
                                        ReminderScheduler.queueReschedule(
                                          city: selected,
                                          prayersEnabled: settings.prayerReminder,
                                          athkarEnabled: false,
                                          l10n: l10n,
                                        );
                                      }
                                      return;
                                    }

                                    // إذا بيشغل: اطلب الإذن أول
                                    final ok = await NotificationService.requestPermissionIfNeeded();
                                    if (!ok) {
                                      // المستخدم رفض/الإشعارات مقفلة من النظام -> لا تغيّر الإعداد
                                      // (السويتش بيظل OFF لأن value مربوط بـ settings.athkarReminder)
                                    _showMiniMessage(
                                            context,
                                            l10n.notificationPermissionRequired, // أو "يرجى السماح بالإشعارات لتفعيل هذا الخيار"
                                            duration: const Duration(seconds: 2),
                                          );
                                      return;
                                    }

                                    // الإذن موجود -> فعّل ثم أعد الجدولة
                                    await settings.setAthkarReminder(true);

                                    final selected = cityProvider.selectedCity ??
                                        (cityProvider.cities.isNotEmpty ? cityProvider.cities.first : null);

                                    if (selected != null) {
                                      ReminderScheduler.queueReschedule(
                                        city: selected,
                                        prayersEnabled: settings.prayerReminder,
                                        athkarEnabled: true,
                                        l10n: l10n,
                                      );
                                    }
                                  },
                                ),

                                const SizedBox(height: 6),
                                Text(
                                  l10n.remindersNote, // أو "ملاحظة: قد تحتاج السماح بالإشعارات"
                                  style: tt.bodySmall?.copyWith(
                                      color: tt.bodySmall?.color
                                          ?.withOpacity(0.7)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ======= Vibration =======
                        _IosSwitchRow(
                          icon: Icons.vibration, // أو Icons.vibration_rounded
                          title: l10n.vibrationMode, // أو "وضع الاهتزاز"
                          subtitle: l10n.vibrationSubtitle,
                          // settings.vibration
                          //     ? l10n.vibrationOn
                          //     : l10n.vibrationOff, // أو "مفعل / معطل"
                          value: settings.vibration,
                          onChanged: (v) => settings.setVibration(v),
                          //  onChanged: (v) => NotificationService.testIn10Seconds(),
                          
                        ),
                   

                        const SizedBox(height: 8),

                        const SizedBox(height: 16),

                        // ======= Font size =======
                        Text(l10n.fontSize, style: tt.titleMedium),
                        Slider(
                          value: settings.fontScale,
                          min: 0.8,
                          max: 1.25,
                          divisions: 6,
                          label: settings.fontScale.toStringAsFixed(1),
                          onChanged: (v) => settings.setFontScale(v),
                        ),
                       
                        const SizedBox(height: 16),


                        // ======= Default settings =======
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  await settings.resetDefaults();
                                  await cityProvider.resetDefaults();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(l10n.resetDone)),
                                    );
                                    Navigator.of(context).maybePop();
                                  }
                                },
                                child: Text(l10n.defaultSettings),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AzanRow extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool isActive;

  const _AzanRow({
    required this.title,
    required this.value,
    required this.icon,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final normalColor = tt.bodyMedium?.color;
    final activeColor = cs.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive ? activeColor : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: tt.bodyMedium?.copyWith(
                  color: isActive ? activeColor : normalColor,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: tt.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isActive ? activeColor : normalColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _IosSwitchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _IosSwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: value ? cs.primary : Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: tt.bodySmall?.copyWith(
                  color: tt.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        CupertinoSwitch(
          value: value,
          activeTrackColor: cs.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}