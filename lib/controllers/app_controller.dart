import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_sking_poc_1/main.dart';
import 'package:go_sking_poc_1/models/rank_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appCtrl = AppController();

class AppController {
  String name = 'User';
  ValueNotifier<int> coin = ValueNotifier(10);
  ValueNotifier<int> sec = ValueNotifier(0);
  final ranksKey = "ranksKey";
  Color color = accentRed;

  double angle = 0;
  double gyro = 0;
  double init = 0;

  late final StreamSubscription subscription = platformE
      .receiveBroadcastStream()
      .listen((event) {
        angle = (event as double).clamp(-pi / 18, pi / 18);
      });

  RankModel? rank;

  SharedPreferences? prefs;

  Future<List<RankModel>> loadRanks() async {
    prefs ??= await SharedPreferences.getInstance();

    return (prefs!.getStringList(ranksKey) ?? [])
        .map((e) => RankModel.fromJson(jsonDecode(e) as Map))
        .toList();
  }

  Future<void> exit() async {
    prefs ??= await SharedPreferences.getInstance();

    final ranks = await loadRanks();
    ranks.add(rank = RankModel(name: name, coin: coin.value, sec: sec.value));
    ranks.sort((a, b) => b.sec - a.sec);

    prefs!.setStringList(
      ranksKey,
      ranks.map((e) => jsonEncode(e.toJson())).toList(),
    );

    coin.value = 10;
    sec.value = 0;
  }

  void snack(BuildContext context, String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
}
