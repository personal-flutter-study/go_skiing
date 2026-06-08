import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:go_skiing_poc_2/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/rank_model.dart';

final appCtrl = AppCtrl();

class AppCtrl {
  Color color = Color(0xffF87373);
  String name = 'User';
  ValueNotifier<int> coin = ValueNotifier(10);
  ValueNotifier<int> sec = ValueNotifier(0);

  ValueNotifier<double> angle = ValueNotifier(0);
  StreamSubscription? subscription;

  void listenAngle() {
    subscription = platformE.receiveBroadcastStream().listen((event) {
      angle.value = (event as double).clamp(-pi / 18, pi / 18);
    });

    subscription?.resume();
  }

  SharedPreferences? prefs;
  final String ranksKey = 'ranksKey';

  RankModel? rank;

  Future<List<RankModel>> loadRanks() async {
    prefs ??= await SharedPreferences.getInstance();

    return (prefs!.getStringList(ranksKey) ?? [])
        .map((e) => RankModel.fromJson(jsonDecode(e)))
        .toList();
  }

  void quit() async {
    final ranks = await loadRanks();
    rank = RankModel(name: name, coin: coin.value, sec: sec.value);
    ranks.add(rank!);
    ranks.sort((a, b) => b.sec - a.sec);

    await prefs!.setStringList(
      ranksKey,
      ranks.map((e) => jsonEncode(e.toJson())).toList(),
    );

    coin.value = 10;
    sec.value = 0;
  }
}
