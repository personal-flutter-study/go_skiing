import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_skiing_poc_2/controllers/app_ctrl.dart';
import 'package:go_skiing_poc_2/main.dart';
import 'package:go_skiing_poc_2/screens/game_screen.dart';
import 'package:go_skiing_poc_2/screens/ranking_screen.dart';
import 'package:go_skiing_poc_2/screens/setting_screen.dart';
import 'package:go_skiing_poc_2/widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            foregroundDecoration: BoxDecoration(
              color: Colors.white.withAlpha(140),
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.jpg'),
                fit: .fill,
              ),
            ),
          ),

          Column(
            mainAxisAlignment: .center,
            children: [
              Text(
                'Go Skiing',
                style: TextStyle(fontWeight: .bold, fontSize: 38),
              ),

              SizedBox(height: 38),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 38.0),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 2),
                    ),
                    hintText: 'Player name',
                    hintStyle: TextStyle(
                      fontWeight: .bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 48),

              SizedBox(
                width: 150,
                child: Column(
                  spacing: 18,
                  children: [
                    button('Start Game', () {
                      if (controller.text.isEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: Text('Invalid'),
                            actions: [
                              CupertinoButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('확인'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      appCtrl.name = controller.text;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GameScreen()),
                      );
                    }),
                    button('Rankings', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RankingScreen(),
                        ),
                      );
                    }),
                    button('Setting', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingScreen(),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
