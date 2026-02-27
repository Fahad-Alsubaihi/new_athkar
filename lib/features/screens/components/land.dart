import 'package:flutter/material.dart';

import '../../../size_config.dart';

class Land extends StatelessWidget {
  const Land({
    Key ?key,
    required this.isFullSun,
  }) : super(key: key);
  final bool isFullSun;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: getProportionateScreenWidth(-20),
      left: 0,
      right: 0,
      child: AnimatedCrossFade(
        // light land
        firstChild: Image.asset(
          "assets/images/morning.png",
          height: getProportionateScreenWidth(195),
          fit: BoxFit.fitHeight,
        ),
        // darkland
        secondChild: Image.asset(
          "assets/images/night.png",
          height: getProportionateScreenWidth(195),
          fit: BoxFit.fitHeight,
        ),
        duration: Duration(milliseconds: 450),

        crossFadeState:
            isFullSun ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        // child:
      ),
    );
  }
}
