import 'package:flutter/material.dart';
import 'package:go_sking_poc_1/controllers/app_controller.dart';
import 'package:go_sking_poc_1/main.dart';
import 'package:go_sking_poc_1/screens/game_screen.dart';
import 'package:go_sking_poc_1/screens/ranking_screen.dart';
import 'package:go_sking_poc_1/screens/setting_screen.dart';

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
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              foregroundDecoration: BoxDecoration(
                color: Colors.white.withAlpha(150),
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bg.jpg'),
                  fit: .fill,
                ),
              ),
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                mainAxisAlignment: .center,
                children: [
                  Text(
                    'Go Skiing',
                    style: TextStyle(fontSize: 38, fontWeight: .bold),
                  ),
                  SizedBox(height: 24),

                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1.5),
                      ),
                      hintText: 'Player name',
                      hintStyle: TextStyle(fontWeight: .bold, fontSize: 20),
                    ),
                  ),

                  SizedBox(height: 38),

                  button('Start Game', () {
                    if (controller.text.isEmpty) {
                      appCtrl.snack(context, 'Invalid');
                      return;
                    }
                    appCtrl.name = controller.text.trim();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GameScreen()),
                    );
                  }),
                  button('Rankings', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RankingScreen()),
                    );
                  }),
                  button('Settings', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingScreen()),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget button(String m, VoidCallback tap) => GestureDetector(
    onTap: tap,
    child: Container(
      margin: .symmetric(horizontal: 88, vertical: 9),
      color: skyBlue,
      padding: .symmetric(vertical: 22),
      alignment: .center,
      child: Text(m, style: TextStyle(fontWeight: .bold, fontSize: 20)),
    ),
  );
}
