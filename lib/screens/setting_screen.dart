import 'package:flutter/material.dart';
import 'package:go_sking_poc_1/controllers/app_controller.dart';

import '../main.dart';

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
    color = .fromColor(appCtrl.color ?? accentRed);
    hue = color.hue;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: .center,
            children: [
              ColorFiltered(
                colorFilter: .mode(color.toColor(), .modulate),
                child: Image.asset(
                  'assets/images/skiing_person.png',
                  fit: .fitWidth,
                  width: 200,
                ),
              ),

              SizedBox(height: 78),

              Padding(
                padding: .symmetric(horizontal: 88),
                child: Theme(
                  data: ThemeData(
                    useMaterial3: false,
                    sliderTheme: SliderThemeData(thumbColor: Colors.white),
                  ),
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
              ),

              SizedBox(height: 48),

              GestureDetector(
                onTap: () {
                  appCtrl.color = color.toColor();
                  Navigator.pop(context);
                },
                child: Container(
                  color: skyBlue,
                  padding: .symmetric(vertical: 12, horizontal: 48),
                  child: Text(
                    'Done',
                    style: TextStyle(fontWeight: .bold, fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
