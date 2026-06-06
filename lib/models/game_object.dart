import 'package:flutter/cupertino.dart';

class GameObject {
  double x, y;
  bool isCoin;
  Widget view;

  GameObject({
    required this.x,
    required this.y,
    required this.isCoin,
    required this.view,
  });
}
