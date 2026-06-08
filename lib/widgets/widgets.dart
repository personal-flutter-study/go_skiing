import 'package:flutter/cupertino.dart';
import 'package:go_skiing_poc_2/main.dart';

Widget button(String m, VoidCallback tap) => GestureDetector(
  onTap: tap,
  child: Container(
    color: sky,
    alignment: .center,
    padding: .symmetric(vertical: 18),
    child: Text(m, style: TextStyle(fontWeight: .bold, fontSize: 18)),
  ),
);

Widget personW({required Color color, double width = 88}) => ColorFiltered(
  colorFilter: .mode(color, .modulate),
  child: Image.asset(
    'assets/images/skiing_person.png',
    fit: .fitWidth,
    width: width,
  ),
);

Widget coinW({double width = 88}) =>
    Image.asset('assets/images/coin.png', fit: .fitWidth, width: width);

Widget blockW({double width = 88}) =>
    Image.asset('assets/images/obstacle.png', fit: .fitWidth, width: width);
