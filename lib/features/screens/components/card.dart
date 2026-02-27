import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/citations.dart';
import '../../../size_config.dart';
import '../../../core/constants/app_text_styles.dart';

import 'counter.dart';

class Card extends StatelessWidget {
  Card({Key? key, required this.length, required this.index}) : super(key: key);

  final int length;
  final int index;

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<Citations>(context);
    final bool isDay = data.isDay ?? true;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.13),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        // ✅ لا تحط SingleChildScrollView حول الكارد كامل
        // خله داخل منطقة النص فقط عشان ما يخرب الـ layout
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  onTap: () => _showInfoSheet(context, data, isDay),
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: const Center(
                      child: Icon(
                        CupertinoIcons.book,
                        size: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Text area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: SizedBox(
                height: getProportionateScreenHeight(310),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if ((data.title ?? '').isNotEmpty)
                              Text(
                                "( ${data.title!} )",
                                textAlign: TextAlign.center,
                                style: AppTextStyles.cardTitleMedium,
                                
                              ),
                            const SizedBox(height: 10),
                            Text(
                              data.data ?? '',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.cardBodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Counter(index: index, length: length),
          ],
        ),
      ],
    );
  }
}

// ===== Bottom sheet =====

void _showInfoSheet(BuildContext context, Citations data, bool isDay) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.transparent,
    elevation: 0,
    clipBehavior: Clip.none,
    isDismissible: true,
    enableDrag: false,
    builder: (_) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDay
                  ? const Color.fromARGB(230, 255, 224, 225)
                  : const Color.fromARGB(200, 0, 0, 0),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "الفائدة",
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.titleMedium?.fontSize ?? 16, // ✅ كبرناها شوي
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Baloo',
                    color: isDay ? Colors.black : Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      data.benifit,
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14, // ✅ كبرناها شوي
                        height: 1.7,
                        fontFamily: 'Baloo',
                        color: isDay ? Colors.black87 : Colors.white70,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
