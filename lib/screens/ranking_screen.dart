import 'package:flutter/material.dart';
import 'package:go_skiing_poc_2/controllers/app_ctrl.dart';
import 'package:go_skiing_poc_2/models/rank_model.dart';
import 'package:go_skiing_poc_2/screens/home_screen.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final List<RankModel> ranks = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      ranks.addAll(await appCtrl.loadRanks());
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Align(
            alignment: .topLeft,
            child: TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                  (route) => false,
                );
              },
              child: Text('back', style: TextStyle(color: Colors.black)),
            ),
          ),

          Text('Rankings', style: TextStyle(fontSize: 32, fontWeight: .bold)),

          SizedBox(height: 28),

          Row(
            children: ['ranking', 'player name', 'coin', 'duration']
                .map(
                  (e) => Expanded(
                    child: Center(
                      child: Text(e, style: TextStyle(fontWeight: .bold)),
                    ),
                  ),
                )
                .toList(),
          ),

          Expanded(
            child: ranks.isNotEmpty
                ? SingleChildScrollView(
                    child: Column(
                      children: ranks.indexed
                          .map(
                            (e) => Container(
                              padding: .symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: .fromLTRB(bottom: BorderSide(width: 2)),
                              ),
                              child: Row(
                                children:
                                    [
                                          e.$1 + 1,
                                          e.$2.name,
                                          e.$2.coin,
                                          "${e.$2.sec} s",
                                        ]
                                        .map(
                                          (i) => Expanded(
                                            child: Center(
                                              child: Text(
                                                '$i',
                                                style: TextStyle(
                                                  fontWeight: .bold,
                                                  color: appCtrl.rank == e.$2
                                                      ? Colors.red
                                                      : Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  )
                : Center(child: Text('No Ranking')),
          ),
        ],
      ),
    );
  }
}
