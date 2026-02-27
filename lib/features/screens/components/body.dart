import 'dart:ui';
import 'package:athkar_new/services/swiper_methods.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

import '../../../providers/settings_provider.dart';
import '../../../data/models/listOfCitations.dart';
import '../../../data/models/citations.dart';
import '../../../data/models/cities.dart';
import '../../../size_config.dart';

import 'cards.dart';
import 'land.dart';
import 'moon.dart';
import 'sun.dart';
import 'tabs.dart';

class Body extends StatefulWidget {
  final void Function(Future<void> Function())? onRegisterReset;

  const Body({
    Key? key,
    this.onRegisterReset,
  }) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  bool isDaytime = true;
  bool isFullSun = true;
  bool isDayMood = true;
  int initialIndex = 0;

  List<Citations> morningdata = [];
  List<Citations> nightdata = [];

  final Duration _duration = const Duration(seconds: 1);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onRegisterReset?.call(resetAllProgressForToday);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await loadDekir();

      // أول مرة: خذ المود من CityProvider
      final p = context.read<CityProvider>();
      _applyMode(p.isDaytime);
    });
  }

  Future<void> resetAllProgressForToday() async {
    await SwiperMethods.clearTodayProgress(
      morningData: morningdata,
      nightData: nightdata,
    );

    // رجّع للوضع التلقائي
    final p = context.read<CityProvider>();
    p.clearManualOverride();
    _applyMode(p.isDaytime);
  }

  void _applyMode(bool newIsDay) {
    if (newIsDay == isDaytime) return;

    setState(() {
      isDaytime = newIsDay;
      isFullSun = newIsDay;
      isDayMood = newIsDay;
      initialIndex = newIsDay ? 0 : 1;
    });
  }

  Future<void> loadDekir() async {
    final repo = context.read<ListOfCitations>();

    final morning = await repo.loadCitations("ARmorning");
    final night = await repo.loadCitations("ARnight");

    if (!mounted) return;
    setState(() {
      morningdata = morning;
      nightdata = night;
    });
  }

  // ✅ التبديل اليدوي (يؤثر على الثيم العام لأن MyApp يقرأ isDaytime من CityProvider)
  Future<void> changeMoodManually(int activeTabNum) async {
    final bool newIsDay = activeTabNum == 0;

    setState(() {
      isDaytime = newIsDay;
      isFullSun = newIsDay;
      isDayMood = newIsDay;
      initialIndex = newIsDay ? 0 : 1;
    });

    await context.read<CityProvider>().setManualMode(newIsDay);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    // ✅ راقب isDaytime من CityProvider (إذا تغير تلقائيًا بسبب المدينة)
    final providerIsDay = context.select<CityProvider, bool>((p) => p.isDaytime);
    if (providerIsDay != isDaytime) {
      // تحديث محلي خفيف بدون loops
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _applyMode(providerIsDay);
      });
    }

    final lightBgColors = AppColors.dayGradient;
    final darkBgColors = AppColors.nightGradient;

    return AnimatedContainer(
      duration: _duration,
      curve: Curves.easeInOut,
      width: double.infinity,
      height: SizeConfig.screenHeight,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDayMood ? lightBgColors : darkBgColors,
          ),
        ),
        child: Stack(
          children: [
            Moon(duration: _duration, isFullSun: isFullSun),
            Sun(duration: _duration, isFullSun: isFullSun),
            Land(isFullSun: isFullSun),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Builder(builder: (ctx) {
                        return IconButton(
                          icon: Icon(
                            Icons.menu,
                            size: getProportionateScreenWidth(30),
                            // ثابت أبيض لأن الخلفية غراديانت
                            color: const Color.fromARGB(181, 255, 255, 255),
                          ),
                          // onPressed: () =>Scaffold.of(context).openEndDrawer(),
                          onPressed: () =>Scaffold.of(context).openDrawer(),
                        );
                      }),
                    ],
                  ),

                  VerticalSpacing(),

                  Tabs(
                    press: (value) async {
                      await changeMoodManually(value);

                      final settings = context.read<SettingsModel>();
                      if (settings.vibration) {
                        Vibration.vibrate(duration: 60);
                      }
                    },
                    initialIndex: initialIndex,
                  ),

                  VerticalSpacing(),

                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isFullSun ? "أذكار الصباح" : "أذكار المساء",
                          // ✅ ثابت للكارد/الواجهة (بدون ما نكتب اللون هنا)
                          style: AppTextStyles.header,
                        ),
                     
                      ],
                    ),
                  ),

                  // VerticalSpacing(),

                  Container(
                    constraints: BoxConstraints(
                      minHeight: getProportionateScreenWidth(200),
                      maxHeight: getProportionateScreenHeight(500),
                    ),
                    child: Cards(
                      data: isFullSun ? morningdata : nightdata,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
