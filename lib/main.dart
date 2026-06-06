import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_sking_poc_1/screens/home_screen.dart';

final platformM = MethodChannel('com/example/go_sking_poc_1_method');
final platformE = EventChannel('com/example/go_sking_poc_1_event');

void main() async {
  runApp(MaterialApp(home: HomeScreen()));
}

const Color skyBlue = Color(0XFF9DD4FA);
const Color yellow = Color(0XFFF7D01C);
const Color accentRed = Color(0XFFF87373);


