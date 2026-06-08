import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_skiing_poc_2/screens/home_screen.dart';

final platformE = EventChannel('com.example.go_skiing_poc_2_e');
final platformM = MethodChannel('com.example.go_skiing_poc_2_m');

void main() async {
  runApp(SafeArea(child: MaterialApp(home: HomeScreen())));
}

const Color sky = Color(0xff9DD4FA);
const Color yellow = Color(0xffF7D01C);
