import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

import '../../../size_config.dart';

class Sun extends StatelessWidget {
  const Sun({
    Key ?key,
    required Duration duration,
    required this.isFullSun,
  })  : _duration = duration,
        super(key: key);

  final Duration _duration;
  final bool isFullSun;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: _duration,
      curve: Curves.easeInOut,
      left: getProportionateScreenWidth(-100),
      bottom: getProportionateScreenHeight(isFullSun ? -60 : -240),
      child: Image(
        image: AssetImage('assets/images/sunblur.png'),
        height: getProportionateScreenHeight(360),
        width: getProportionateScreenWidth(360),
      ),
      // SvgPicture.asset("assets/icons/Sun.svg"),
    );
  }
}
