import 'package:flutter/material.dart';
import 'package:go_skiing_poc_2/controllers/app_ctrl.dart';
import 'package:go_skiing_poc_2/widgets/widgets.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late HSVColor color;
  late double hue;

  @override
  void initState() {
    color = .fromColor(appCtrl.color);
    hue = color.hue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: .center,
        children: [
          personW(color: color.toColor(), width: 200),

          SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 38.0, horizontal: 78),
            child: Slider(
              min: 0,
              value: hue,
              max: 255,
              onChanged: (value) {
                setState(() {
                  hue = value;
                  color = color.withHue(hue);
                });
              },
            ),
          ),

          SizedBox(
            width: 150,
            child: button('Done', () {
              appCtrl.color = color.toColor();
              Navigator.pop(context);
            }),
          ),
        ],
      ),
    );
  }
}
