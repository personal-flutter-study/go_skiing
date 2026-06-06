import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_sking_poc_1/controllers/app_controller.dart';
import 'package:go_sking_poc_1/main.dart';
import 'package:go_sking_poc_1/models/game_object.dart';
import 'package:go_sking_poc_1/widgets/game_over_dialog.dart';

int _slow = 900;
int _normal = 600;
int _fast = 300;

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late final AnimationController tree;
  late final AnimationController person;

  bool stop = false;
  bool jumping = false;
  bool invincibilityMode = false;
  double offset = 0;

  Timer? timer;
  Timer? gameTimer;
  bool gameOver = false;
  late final double init;
  bool reset = true;

  final List<GameObject> gameObjects = [];

  @override
  void initState() {
    super.initState();

    // 기기 기울기 값 가져오기
    appCtrl.subscription.resume();
    init = appCtrl.angle;

    // 움직임 animation 설정
    tree = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _normal),
    );

    person = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      tree.repeat();

      // 배경음악 시작
      platformM.invokeMethod('start').then((value) {
        print("start : $value");
      });

      final width = MediaQuery.widthOf(context);

      /// 일반 timer 설정
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (stop || appCtrl.angle.abs() < pi / 36) return;

        // 시간 ++
        appCtrl.sec.value++;

        // 무적 모드일 시 coin 차감
        if (invincibilityMode) {
          appCtrl.coin.value--;
          if (appCtrl.coin.value <= 0) {
            setState(() {
              invincibilityMode = false;
            });
          }
        }

        // game object 생성
        final n = Random().nextInt(100);

        if (n < 10) {
          // coin
          gameObjects.add(
            GameObject(x: -50, y: 0, isCoin: true, view: _coin()),
          );
        } else if (n < 20) {
          gameObjects.add(
            // block
            GameObject(x: -50, y: 0, isCoin: false, view: _block()),
          );
        }
      });

      /// game timer 설정
      gameTimer = Timer.periodic(Duration(milliseconds: 16), (timer) {
        setState(() {});

        // 기울기 수평일 시 정지
        if (stop || appCtrl.angle.abs() < pi / 36) {
          tree.stop();
          return;
        } else {
          if (!tree.isAnimating) tree.repeat();
        }

        if (stop) return;

        // game object 움직임 구현
        for (var i in List.of(gameObjects)) {
          final fast = appCtrl.angle > pi / 20 || offset > 200;
          final slow = appCtrl.angle < -pi / 20;

          if (slow) {
            if (tree.duration != Duration(milliseconds: _slow)) {
              platformM.invokeMethod('volume', .5);
              tree.duration = Duration(milliseconds: _slow);
              tree.repeat();
              reset = false;
            }
          }

          if (!reset && !slow) {
            tree.duration = Duration(milliseconds: _normal);
            tree.repeat();
            platformM.invokeMethod('volume', 1.0);
            reset = true;
          }

          i.x += fast
              ? 5
              : slow
              ? 1
              : 3;
          i.y = ((i.x - width / 2) * tan(appCtrl.angle)).clamp(-60, 60);

          // 충돌 감지
          if (width / 2 - 80 <= i.x && width / 2 + 40 >= i.x && !jumping) {
            if (i.isCoin) {
              appCtrl.coin.value += 1;
              gameObjects.remove(i);
              // coin 효과음
              platformM.invokeMethod('coin').then((value) {
                print("coin : $value");
              });
            } else if (!invincibilityMode) {
              gameOver = true;
              stop = true;
              tree.stop();
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => GameOverDialog(),
              );
              // game over 효과음
              platformM.invokeMethod('gameOver').then((value) {
                print("gameOver : $value");
              });
            }
          }

          // 화면 밖 나가면 list에서 삭제
          if (i.x > width + 50) {
            gameObjects.remove(i);
          }
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onLongPressStart: (details) {
          if (appCtrl.coin.value > 0) {
            setState(() {
              invincibilityMode = true;
            });
          }
        },
        onLongPressEnd: (details) {
          setState(() {
            invincibilityMode = false;
          });
        },
        onVerticalDragUpdate: (details) {
          offset = (offset + details.delta.dy).clamp(0, 300);
          if (offset > 200) {
            tree.duration = Duration(milliseconds: _fast);
            tree.repeat();
          }
        },
        onVerticalDragEnd: (details) {
          tree.duration = Duration(milliseconds: _normal);
          tree.repeat();
          offset = 0;
        },
        onHorizontalDragUpdate: (details) async {
          if (details.delta.dx.abs() > 10) {
            stop = true;
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Center(child: Text('게임 중 종료 확인')),
                actionsAlignment: .center,
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('No'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: Text('Yes'),
                  ),
                ],
              ),
            );

            stop = false;
          }
        },
        onTap: () {
          if (!jumping) {
            jumping = true;
            person.forward().then((value) {
              person.reverse().then((value) {
                jumping = false;
              });
            });
          }
        },
        child: Scaffold(
          body: Stack(
            clipBehavior: .none,
            children: [
              //background
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bg.jpg'),
                    fit: .fill,
                  ),
                ),
              ),

              //tree
              AnimatedBuilder(
                animation: tree,
                builder: (context, child) {
                  return Transform.translate(
                    offset: .new(-298 * tree.value, .0),
                    child: OverflowBox(
                      maxWidth: 1000,
                      child: Align(
                        alignment: .bottomLeft,
                        child: Image.asset(
                          'assets/images/trees.png',
                          fit: .fitWidth,
                        ),
                      ),
                    ),
                  );
                },
              ),

              //body
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  stop = !stop;
                                });
                              },
                              icon: Icon(
                                stop ? Icons.play_arrow : Icons.pause,
                                color: Colors.black,
                                size: 48,
                              ),
                            ),
                            Text(
                              appCtrl.name,
                              style: TextStyle(fontWeight: .bold, fontSize: 18),
                            ),
                          ],
                        ),

                        Row(
                          spacing: 6,
                          mainAxisAlignment: .end,
                          children: [
                            _coin(),
                            ValueListenableBuilder(
                              valueListenable: appCtrl.coin,
                              builder: (context, value, child) => Text(
                                value.toString(),
                                style: TextStyle(
                                  fontWeight: .bold,
                                  color: yellow,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: .topRight,
                          child: ValueListenableBuilder(
                            valueListenable: appCtrl.sec,
                            builder: (context, value, child) => Text(
                              '$value s',
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.black,
                                fontWeight: .bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          bottom: 50,
                          child: AnimatedBuilder(
                            animation: person,
                            builder: (context, child) {
                              return Align(
                                alignment: .bottomCenter,
                                child: Transform.translate(
                                  offset: .new(
                                    0,
                                    -120 * (stop ? 0 : person.value),
                                  ),
                                  child: Transform.rotate(
                                    angle: appCtrl.angle,
                                    child: ColorFiltered(
                                      colorFilter: .mode(
                                        appCtrl.color,
                                        .modulate,
                                      ),
                                      child: Image.asset(
                                        'assets/images/skiing_person.png',
                                        fit: .fitWidth,
                                        width: 120,
                                        color: invincibilityMode
                                            ? Colors.black
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // game object list
                        ...gameObjects.map(
                          (e) => Positioned(
                            right: e.x,
                            bottom: e.y + 60,
                            child: e.view,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              OverflowBox(
                maxWidth: 500,
                child: Align(
                  alignment: .bottomCenter,
                  child: Transform.translate(
                    offset: .new(0, 150),
                    child: Transform.rotate(
                      angle: appCtrl.angle,
                      alignment: .topCenter,
                      child: Container(color: Colors.white, height: 200),
                    ),
                  ),
                ),
              ),

              if (stop)
                IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(100),
                    ),
                    alignment: .center,
                    child: Text(
                      "Game suspended",
                      style: TextStyle(
                        fontWeight: .bold,
                        color: Colors.white,
                        fontSize: 28,
                      ),
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

Widget _coin([double size = 38]) => SizedBox.square(
  dimension: size,
  child: Image.asset('assets/images/coin.png'),
);

Widget _block([double size = 38]) => SizedBox.square(
  dimension: size,
  child: Image.asset('assets/images/obstacle.png'),
);
