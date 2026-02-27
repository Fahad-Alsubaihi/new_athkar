import 'package:athkar_new/data/models/cities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:athkar_new/gen_l10n/app_localizations.dart';

import 'features/screens/login/login_screen.dart';
import 'data/models/listOfCitations.dart';
import 'data/models/citations.dart';
import 'providers/settings_provider.dart';
import 'core/theme/app_theme.dart';

import 'services/reminder_scheduler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const AppProviders());
}

/// فصلنا الـ providers في Widget مستقل (أفضل للمستقبل)
class AppProviders extends StatelessWidget {
  const AppProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Citations(currentc: 0, benifit: ''),
        ),
        ChangeNotifierProvider(
          create: (_) => ListOfCitations(),
        ),

        // Settings
        ChangeNotifierProvider(
          create: (_) {
            final s = SettingsModel();
            s.load(); // تحميل مرة واحدة (async داخلي)
            return s;
          },
        ),

        // City
        ChangeNotifierProvider(
          create: (_) {
            final c = CityProvider();
            c.loadCities(); // تحميل مرة واحدة (async داخلي)
            return c;
          },
        ),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // أقل rebuild
    final languageCode =
        context.select<SettingsModel, String>((s) => s.languageCode);
    final fontScale =
        context.select<SettingsModel, double>((s) => s.fontScale);
    final isDaytime = context.select<CityProvider, bool>((c) => c.isDaytime);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // ✅ Localization (gen-l10n)
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale(languageCode),

      // Themes
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDaytime ? ThemeMode.light : ThemeMode.dark,

      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: TextScaler.linear(fontScale),
          ),
          child: child!,
        );
      },

      // ✅ هنا نضيف Bootstrap عشان نعمل ensureScheduledToday مرة واحدة
      home: const _SchedulerBootstrap(child: LoginScreen()),
    );
  }
}

/// Widget صغير يشغّل ensureScheduledToday مرة واحدة لما تتوفر (City + Settings + l10n)
class _SchedulerBootstrap extends StatefulWidget {
  final Widget child;
  const _SchedulerBootstrap({required this.child});

  @override
  State<_SchedulerBootstrap> createState() => _SchedulerBootstrapState();
}

class _SchedulerBootstrapState extends State<_SchedulerBootstrap> {
  bool _done = false;

  VoidCallback? _cityListener;
  VoidCallback? _settingsListener;

  @override
  void initState() {
    super.initState();

    // نخلي الاستدعاء بعد أول frame عشان AppLocalizations يصير جاهز
    WidgetsBinding.instance.addPostFrameCallback((_) => _trySchedule());

    // نسمع تغييرات providers لأن loadCities/load قد تتأخر
    _cityListener = () => _trySchedule();
    _settingsListener = () => _trySchedule();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // اربط listeners مرة واحدة
    final cityProvider = context.read<CityProvider>();
    final settings = context.read<SettingsModel>();

    // منع تكرار الإضافة
    cityProvider.removeListener(_cityListener!);
    settings.removeListener(_settingsListener!);

    cityProvider.addListener(_cityListener!);
    settings.addListener(_settingsListener!);
  }

  Future<void> _trySchedule() async {
    if (_done || !mounted) return;

    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    final cityProvider = context.read<CityProvider>();
    final settings = context.read<SettingsModel>();

    final city = cityProvider.selectedCity ??
        (cityProvider.cities.isNotEmpty ? cityProvider.cities.first : null);

    // إذا لسه المدن ما حملت، ننتظر لين يجي listener مرة ثانية
    if (city == null) return;

    _done = true;
if(settings.prayerReminder || settings.athkarReminder )
    await ReminderScheduler.ensureScheduledToday(
      city: city,
      prayersEnabled: settings.prayerReminder,
      athkarEnabled: settings.athkarReminder,
      l10n: l10n,
      // daysAhead: 2,
    );
  }

  @override
  void dispose() {
    // تنظيف listeners
    final cityProvider = context.read<CityProvider>();
    final settings = context.read<SettingsModel>();

    if (_cityListener != null) {
      cityProvider.removeListener(_cityListener!);
    }
    if (_settingsListener != null) {
      settings.removeListener(_settingsListener!);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}