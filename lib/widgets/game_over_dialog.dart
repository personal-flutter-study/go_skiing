import 'package:flutter/material.dart';
import 'package:go_skiing_poc_2/controllers/app_ctrl.dart';
import 'package:go_skiing_poc_2/main.dart';
import 'package:go_skiing_poc_2/screens/game_screen.dart';
import 'package:go_skiing_poc_2/screens/ranking_screen.dart';
import 'package:go_skiing_poc_2/widgets/widgets.dart';

class GameOverDialog extends StatelessWidget {
  const GameOverDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: .zero),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: .start,
          mainAxisSize: .min,
          spacing: 12,
          children: [
            Text(
              'Game Over',
              style: TextStyle(fontWeight: .bold, fontSize: 28),
            ),
            Text(
              'Player name: ${appCtrl.name}',
              style: TextStyle(fontWeight: .bold, fontSize: 28),
            ),
            Row(
              spacing: 8,
              children: [
                coinW(width: 24),
                Text(
                  appCtrl.coin.value.toString(),
                  style: TextStyle(
                    fontWeight: .bold,
                    fontSize: 28,
                    color: yellow,
                  ),
                ),
              ],
            ),
            Text(
              'time: ${appCtrl.sec.value}',
              style: TextStyle(fontWeight: .bold, fontSize: 28),
            ),

            SizedBox(height: 8),

            Row(
              mainAxisAlignment: .end,
              spacing: 12,
              children: [
                GestureDetector(
                  onTap: () {
                    appCtrl.quit();
                    Navigator.of(context)
                      ..pop()
                      ..pushReplacement(
                        MaterialPageRoute(builder: (context) => GameScreen()),
                      );
                  },
                  child: Text(
                    'Restart',
                    style: TextStyle(fontWeight: .bold, fontSize: 22),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    appCtrl.quit();
                    Navigator.of(context)
                      ..pop()
                      ..pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => RankingScreen(),
                        ),
                      );
                  },
                  child: Text(
                    'Go To Rankings',
                    style: TextStyle(fontWeight: .bold, fontSize: 22),
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
