import 'package:flutter/material.dart';
import '../../../size_config.dart';

class Tabs extends StatelessWidget {
  const Tabs({
    Key? key,
    required this.press,
    required this.initialIndex, // Added parameter for initial index
  }) : super(key: key);

  final ValueChanged<int> press;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeConfig.screenWidth! * 0.8, // 80%
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DefaultTabController(
        // Key depends on the requested initialIndex so that when the
        // parent rebuilds with a different index (e.g. day/night auto-
        // detection), the DefaultTabController will be recreated and
        // honor the new initialIndex.
        key: ValueKey(initialIndex),
        length: 2,
        initialIndex: initialIndex, // Set the initial tab
        child: TabBar(
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          labelColor: Colors.black,
          unselectedLabelColor: Colors.white,
          onTap: press,
          tabs: [
            Tab(
              icon: Icon(
                Icons.sunny,
                size: getProportionateScreenWidth(30),
              ),
            ),
            Tab(
              icon: Icon(
                Icons.mode_night,
                size: getProportionateScreenWidth(30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
