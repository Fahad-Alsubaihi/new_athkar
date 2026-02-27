import 'package:athkar_new/providers/settings_provider.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/swiper_methods.dart';
import '../../../data/models/citations.dart';
import '../../../data/models/cities.dart';
import 'card.dart' as citation_card;

class Cards extends StatefulWidget {
  final List<Citations> data;

  const Cards({Key? key, required this.data}) : super(key: key);

  @override
  State<Cards> createState() => _CardsState();
}

class _CardsState extends State<Cards> {
  String? _lastRestoreKey; // cityKey + mode + length

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _restoreIfNeeded();
  }

  @override
  void didUpdateWidget(covariant Cards oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _restoreIfNeeded();
    }
  }

void _restoreIfNeeded() {
  if (!mounted) return;

  final cityProvider = context.read<CityProvider>();
  final cityKey = cityProvider.selectedCityKey;

  // ✅ وقت المدينة الحقيقي (لا يتأثر باليدوي)
  final realCityIsDaytime = cityProvider.realCityIsDaytime;

  // ✅ مود العرض الحالي جاي من الداتا نفسها (morning/night list)
  final viewIsDay = widget.data.isNotEmpty ? (widget.data.first.isDay ?? true) : true;
  final viewTag = viewIsDay ? 'morning' : 'evening';

  // ✅ restoreKey يعتمد على مود العرض + المدينة + طول القائمة فقط
  final restoreKey = "$cityKey:$viewTag:${widget.data.length}";

  if (_lastRestoreKey == restoreKey) return;
  _lastRestoreKey = restoreKey;

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (!mounted) return;

    await SwiperMethods.stopPoint(
      data: widget.data,
      cityKey: cityKey,
      cityIsDaytime: realCityIsDaytime, // ✅ مهم جدًا
    );
  });
}

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
final lang = context.select<SettingsModel, String>((s) => s.languageCode);
final swiperDir = (lang == 'ar') ? TextDirection.rtl : TextDirection.ltr;
    return Directionality(
      textDirection: swiperDir, 
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          return ChangeNotifierProvider.value(
            value: data[index],
            child: citation_card.Card(
              index: index,
              length: data.length,
            ),
          );
        },
        itemCount: data.length,
        loop: false,
        viewportFraction: 0.9,
        scale: 0.5,
        controller: SwiperMethods.controller,
      ),
    );
  }
}
