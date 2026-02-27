import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';


import 'package:athkar_new/providers/settings_provider.dart';
import 'package:athkar_new/size_config.dart';

import '../../../data/models/cities.dart';
import '../../../services/swiper_methods.dart';
import '../../../data/models/citations.dart';

class Counter extends StatelessWidget {
  const Counter({Key? key, required this.length, required this.index})
      : super(key: key);

  final int length;
  final int index;

  @override
  Widget build(BuildContext context) {
    final citation = context.watch<Citations>();
    final settings = context.watch<SettingsModel>();

    final cityProvider = context.read<CityProvider>();
    final cityKey = cityProvider.selectedCityKey;
    final cityIsDaytime = cityProvider.realCityIsDaytime; // ✅ وقت المدينة الحقيقي

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
            onTap: () async {
              if (citation.currentc != 0) {
                citation.reload();

                  await SwiperMethods.saveProgressIfCityMode(
                    cityKey: cityKey,
                    isDay: citation.isDay ?? true,
                    cityIsDaytime: cityIsDaytime,
                    index: index,
                    counter: citation.currentc,
                  );
                if (settings.vibration) Vibration.vibrate(duration: 100);
              }
            },
            child: Center(
              child: Icon(
                CupertinoIcons.restart,
                size: 30,
                //  size: getProportionateScreenWidth(30*settings.fontScale),
                color: Colors.white,
              ),
            ),
          ),
          Stack(
            children: [
              CircularPercentIndicator(
                radius: getProportionateScreenWidth(53),
                lineWidth: getProportionateScreenWidth(9),
                animation: false,
                percent: (citation.counter == null || citation.counter == 0)
                    ? 0
                    : (citation.currentc / citation.counter!).clamp(0.0, 1.0),
backgroundColor: (citation.isDay ?? true)
    ? AppColors.morningProgress
    : AppColors.eveningProgress,
                center: InkWell(
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(60),
                  ),
                  onTap: () async {
                    final remaining = (citation.counter ?? 0) - citation.currentc;
                    if (remaining != 0) {
                      citation.increment();

   await SwiperMethods.saveProgressIfCityMode(
  cityKey: cityKey,
  isDay: citation.isDay ?? true,
  cityIsDaytime: cityIsDaytime,
  index: index,
  counter: citation.currentc,
);

                      if (settings.vibration) Vibration.vibrate(duration: 60);

                      if (citation.counter == citation.currentc) {
                        SwiperMethods.goNext(index, citation.isDay ?? true);
                      }
                    }
                  },
                  child: SizedBox(
                    width: getProportionateScreenWidth(90),
                    height: getProportionateScreenWidth(90),
                    child: Center(
                      child: Text(
                        "${(citation.counter ?? 0) - citation.currentc}",
                       style: AppTextStyles.counter,

                      ),
                    ),
                  ),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: Colors.white,
              ),
            ],
          ),
          Text(
            "${index + 1} / $length",
            style: const TextStyle(
              fontFamily: 'Baloo',
              fontSize: 17,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
