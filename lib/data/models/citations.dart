import 'package:flutter/foundation.dart';

class Citations with ChangeNotifier {
  String? title;
  String? data;
  int? counter;
  String benifit;
  int currentc;
  bool? isDay;

  Citations({
    this.isDay,
    this.counter,
    required this.currentc,
    this.data,
    this.title,
    required this.benifit,
  });

  factory Citations.fromJson(Map<String, dynamic> json) {
    return Citations(
      isDay: json['time'] == 1, // 1 morning, 0 evening
      counter: json['counter'] ?? 0,
      currentc: json['currentc'] ?? 0,
      data: json['data'] ?? '',
      title: json['title'] ?? '',
      benifit: json['benifit'] ?? '',
    );
  }

  void complete() {
    currentc = counter ?? 0;
    notifyListeners();
  }

  void increment() {
    final max = counter ?? 0;
    if (currentc < max) {
      currentc++;
      notifyListeners();
    }
  }

  void reload() {
    currentc = 0;
    notifyListeners();
  }

  void reset() {
    currentc = 0;
    // intentionally no notify (batch resets)
  }
}
