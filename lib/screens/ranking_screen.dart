import 'package:flutter/material.dart';
import 'package:go_sking_poc_1/controllers/app_controller.dart';
import 'package:go_sking_poc_1/models/rank_model.dart';
import 'package:go_sking_poc_1/screens/home_screen.dart';

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
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            children: [
              SizedBox(height: 8),

              Align(
                alignment: .topLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                      (route) => false,
                    );
                  },
                  child: Text("back", style: TextStyle(fontSize: 18)),
                ),
              ),

              Text(
                "Rankings",
                style: TextStyle(fontWeight: .bold, fontSize: 38),
              ),

              SizedBox(height: 24),

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
                                  height: 38,
                                  decoration: BoxDecoration(
                                    border: .fromLTRB(bottom: BorderSide()),
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
                                                    "$i",
                                                    style: TextStyle(
                                                      fontWeight: .bold,
                                                      color:
                                                          appCtrl.rank == e.$2
                                                          ? Colors.red
                                                          : null,
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
                    : Center(
                        child: Text(
                          "No Ranking",
                          style: TextStyle(fontWeight: .bold, fontSize: 38),
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
