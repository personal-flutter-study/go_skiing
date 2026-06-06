import 'package:flutter/material.dart';
import 'package:go_sking_poc_1/controllers/app_controller.dart';
import 'package:go_sking_poc_1/main.dart';
import 'package:go_sking_poc_1/screens/game_screen.dart';
import 'package:go_sking_poc_1/screens/ranking_screen.dart';

class GameOverDialog extends StatelessWidget {
  const GameOverDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: .zero),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: .min,
          spacing: 12,
          crossAxisAlignment: .start,
          children: [
            Text(
              'Game Over',
              style: TextStyle(fontWeight: .bold, fontSize: 24),
            ),
            Text(
              'Player name : ${appCtrl.name}',
              style: TextStyle(fontWeight: .bold, fontSize: 24),
            ),

            Row(
              children: [
                Image.asset(
                  'assets/images/coin.png',
                  fit: .fitWidth,
                  width: 32,
                ),
                Text(
                  appCtrl.coin.value.toString(),
                  style: TextStyle(
                    fontWeight: .bold,
                    color: yellow,
                    fontSize: 24,
                  ),
                ),
              ],
            ),

            Text(
              'time : ${appCtrl.sec.value}s',
              style: TextStyle(fontWeight: .bold, fontSize: 24),
            ),

            SizedBox(height: 8),

            Row(
              mainAxisAlignment: .end,
              children: [
                GestureDetector(
                  onTap: () {
                    final name = appCtrl.name;
                    appCtrl.exit();
                    appCtrl.name = name;
                    Navigator.of(context)
                      ..pop
                      ..pushReplacement(
                        MaterialPageRoute(builder: (context) => GameScreen()),
                      );
                  },
                  child: Text(
                    "Restart",
                    style: TextStyle(fontWeight: .bold, fontSize: 18),
                  ),
                ),
                SizedBox(width: 18),

                GestureDetector(
                  onTap: () {
                    appCtrl.exit();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => RankingScreen()),
                    );
                  },
                  child: Text(
                    "Go To Rankings",
                    style: TextStyle(fontWeight: .bold, fontSize: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
