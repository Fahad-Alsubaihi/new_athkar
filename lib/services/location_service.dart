import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  LocationService._();

  static Future<Position?> getCurrentPositionSafe() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      debugPrint('LOC enabled=$enabled');
      if (!enabled) return null;

      var perm = await Geolocator.checkPermission();
      debugPrint('LOC permission(before)=$perm');

      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        debugPrint('LOC permission(after request)=$perm');
      }

      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return null;
      }

      final last = await Geolocator.getLastKnownPosition();
      debugPrint('LOC lastKnown=${last?.latitude},${last?.longitude}');
      if (last != null) return last;

      // ✅ طريقة أدق وأثبت: نسمع أول تحديث موقع
      const settings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      );

      final pos = await Geolocator.getPositionStream(locationSettings: settings)
          .first
          .timeout(const Duration(seconds: 45));

      debugPrint('LOC stream=${pos.latitude},${pos.longitude}');
      return pos;
    } on TimeoutException {
      debugPrint('LOC timeout');
      return null;
    } catch (e) {
      debugPrint('LOC error=$e');
      return null;
    }
  }
}