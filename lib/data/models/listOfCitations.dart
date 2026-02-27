// import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';
import 'citations.dart';

class ListOfCitations with ChangeNotifier {

  Future<List<Citations>> loadCitations(String key) async {
    final raw = await rootBundle.loadString('assets/data/dekir.json');
    final decoded = jsonDecode(raw);

    if (decoded is! Map<String, dynamic>) {
      throw Exception("dekir.json must be a Map, got ${decoded.runtimeType}");
    }

    final list = decoded[key];
    if (list is! List) {
      throw Exception("Key '$key' not found or not a List. Available keys: ${decoded.keys.toList()}");
    }

    return list
        .map((e) => Citations.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
