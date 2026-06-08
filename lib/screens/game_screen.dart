import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_skiing_poc_2/controllers/app_ctrl.dart';
import 'package:go_skiing_poc_2/main.dart';
import 'package:go_skiing_poc_2/models/game_model.dart';
import 'package:go_skiing_poc_2/screens/home_screen.dart';
import 'package:go_skiing_poc_2/widgets/game_over_dialog.dart';
import 'package:go_skiing_poc_2/widgets/widgets.dart';
import 'package:video_player/video_player.dart';

const (Duration, int) _slow = (Duration(milliseconds: 900), 2);
const (Duration, int) _normal = (Duration(milliseconds: 600), 4);
const (Duration, int) _fast = (Duration(milliseconds: 300), 6);

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final VideoPlayerController bgA = VideoPlayerController.asset(
    'assets/audio/bgm.mp3',
    videoPlayerOptions: .new(mixWithOthers: true),
  );
  final VideoPlayerController coinA = VideoPlayerController.asset(
    'assets/audio/coin.wav',
    videoPlayerOptions: .new(mixWithOthers: true),
  );
  final VideoPlayerController jumpA = VideoPlayerController.asset(
    'assets/audio/jump.wav',
    videoPlayerOptions: .new(mixWithOthers: true),
  );
  final VideoPlayerController gameOverA = VideoPlayerController.asset(
    'assets/audio/game_over.wav',
    videoPlayerOptions: .new(mixWithOthers: true),
  );

  late final AnimationController treeAni;
  late final AnimationController jump;

  ValueNotifier<bool> stop = ValueNotifier(false);
  ValueNotifier<(Duration, int)> speed = ValueNotifier(_normal);
  bool special = false;
  bool speedUp = false;

  Timer? secTimer;
  Timer? gameTimer;
  ValueNotifier<int> gameTicker = ValueNotifier(0);

  final List<GameModel> objects = [];

  late final double initAngle;

  @override
  void initState() {
    super.initState();
    treeAni = AnimationController(vsync: this, duration: _normal.$1);
    jump = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    appCtrl.listenAngle();
    initAngle = appCtrl.angle.value;

    stop.addListener(stopListener);
    speed.addListener(speedListener);
    appCtrl.angle.addListener(angleListener);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      platformM.invokeMethod('vibrate').then((value) {
        print(value);
      });
      bgA.initialize().then((value) {
        bgA.setLooping(true);
        bgA.play();
      });
      await jumpA.initialize();
      await coinA.initialize();
      await gameOverA.initialize();

      treeAni.repeat();

      secTimer = timer1;
      gameTimer = timer2;
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    secTimer?.cancel();
    stop.removeListener(stopListener);
    speed.removeListener(speedListener);
    appCtrl.angle.removeListener(angleListener);
    super.dispose();
  }

  double offsetV = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onLongPressStart: (details) {
          if (appCtrl.coin.value > 0) {
            special = true;
            setState(() {});
          }
        },
        onLongPressEnd: (details) {
          special = false;
          setState(() {});
        },
        onVerticalDragUpdate: (details) {
          offsetV = (offsetV + details.delta.dy).clamp(0, 300);
          if (offsetV > 200) {
            speed.value = _fast;
            speedUp = true;
          }
        },
        onVerticalDragEnd: (details) {
          offsetV = 0;
          speedUp = false;
          speed.value = _normal;
        },
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx > 10) {
            showDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                title: Text('게임 중 종료 확인'),
                actions: [
                  CupertinoButton(
                    child: Text('Yes'),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                        (route) => false,
                      );
                    },
                  ),
                  CupertinoButton(
                    child: Text('No'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          }
        },
        onTap: () async {
          if (!jump.isAnimating) {
            jumpA.play();
            jump.forward().then((value) {
              jump.reverse();
            });
          }
        },
        child: Stack(
          children: [
            background(),
            tree(),
            Column(
              children: [
                topBar(),
                Expanded(child: body()),
              ],
            ),
            forOverlay(),
          ],
        ),
      ),
    );
  }

  Widget forOverlay() {
    if (stop.value) {
      return IgnorePointer(
        child: Container(
          color: Colors.black.withAlpha(100),
          alignment: .center,
          child: Text(
            'Game suspended...',
            style: TextStyle(
              color: Colors.white,
              fontWeight: .bold,
              fontSize: 28,
            ),
          ),
        ),
      );
    }

    if (special) {
      return IgnorePointer(
        child: Container(
          color: Colors.black.withAlpha(100),
          alignment: .center,
          child: Text(
            'Invincibility Mode',
            style: TextStyle(
              color: Colors.white,
              fontWeight: .bold,
              fontSize: 28,
            ),
          ),
        ),
      );
    }

    return SizedBox.shrink();
  }

  Widget body() => ListenableBuilder(
    listenable: Listenable.merge([appCtrl.angle, gameTicker]),
    builder: (context, child) => Stack(
      children: [
        Transform.translate(
          offset: .new(0, -50),
          child: Transform.rotate(
            angle: appCtrl.angle.value,
            child: Stack(
              clipBehavior: .none,
              children: [
                Align(
                  alignment: .bottomCenter,
                  child: AnimatedBuilder(
                    animation: jump,
                    builder: (context, child) => Transform.translate(
                      offset: .new(0, -120 * jump.value),
                      child: personW(
                        color: special ? Colors.black : appCtrl.color,
                        width: 108,
                      ),
                    ),
                  ),
                ),

                ...objects.map(
                  (e) => Positioned(
                    right: e.x,
                    bottom: 0,
                    child: e.isCoin ? coinW(width: 50) : blockW(width: 50),
                  ),
                ),
              ],
            ),
          ),
        ),
        Transform.translate(
          offset: .new(0, 100),
          child: Transform.rotate(
            angle: appCtrl.angle.value,
            child: OverflowBox(
              maxWidth: MediaQuery.widthOf(context) + 200,
              child: Align(
                alignment: .bottomCenter,
                child: Container(height: 150, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget topBar() => Padding(
    padding: const EdgeInsets.all(18.0),
    child: Column(
      spacing: 4,
      children: [
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  stop.value = !stop.value;
                });
              },
              icon: Icon(
                stop.value ? Icons.play_arrow : Icons.pause,
                color: Colors.black,
                size: 48,
              ),
            ),

            Text(
              appCtrl.name,
              style: TextStyle(fontWeight: .bold, fontSize: 24),
            ),
          ],
        ),

        Row(
          mainAxisAlignment: .end,
          spacing: 4,
          children: [
            coinW(width: 28),
            ValueListenableBuilder(
              valueListenable: appCtrl.coin,
              builder: (context, value, child) => Text(
                appCtrl.coin.value.toString(),
                style: TextStyle(
                  color: yellow,
                  fontWeight: .bold,
                  fontSize: 24,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: .end,
          children: [
            ValueListenableBuilder(
              valueListenable: appCtrl.sec,
              builder: (context, value, child) => Text(
                '${appCtrl.sec.value} s',
                style: TextStyle(fontWeight: .bold, fontSize: 24),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget background() => Container(
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/bg.jpg'),
        fit: .fill,
      ),
    ),
  );

  Widget tree() => Align(
    alignment: .bottomCenter,
    child: SizedBox(
      height: 400,
      child: AnimatedBuilder(
        animation: treeAni,
        builder: (context, child) {
          final width = MediaQuery.widthOf(context);
          return Stack(
            children: [
              Positioned(
                right: -width + width * treeAni.value,
                child: Image.asset('assets/images/trees.png'),
              ),
              Positioned(
                right: width + width * treeAni.value,
                child: Image.asset('assets/images/trees.png'),
              ),
            ],
          );
        },
      ),
    ),
  );
}

extension GameCtrl on _GameScreenState {
  void speedListener() {
    treeAni.duration = speed.value.$1;
    treeAni.repeat();
  }

  void stopListener() {
    if (stop.value) {
      treeAni.stop();
      bgA.pause();
    } else {
      treeAni.repeat();
      bgA.play();
    }
  }

  void angleListener() {
    if (stop.value) return;

    if (appCtrl.angle.value.abs() <= .001) {
      if (treeAni.isAnimating) {
        treeAni.stop();
      }
      return;
    }
    if (speed.value != _normal && !speedUp && appCtrl.angle.value > pi / 36) {
      speed.value = _normal;
    } else if (speed.value != _slow &&
        !speedUp &&
        appCtrl.angle.value < -pi / 36) {
      speed.value = _slow;
    }
  }

  Timer get timer1 => Timer.periodic(Duration(seconds: 1), (timer) {
    if (stop.value) return;
    if (!treeAni.isAnimating) return;
    appCtrl.sec.value++;

    if (special) {
      if (appCtrl.coin.value > 0) {
        appCtrl.coin.value--;
      } else {
        special = false;
      }
    }

    final n = Random().nextInt(100);

    if (n < 10) {
      objects.add(GameModel(x: -50, isCoin: false));
      print("add block");
    } else if (n < 30) {
      objects.add(GameModel(x: -50, isCoin: true));
      print("add coin");
    }
  });

  Timer get timer2 {
    final width = MediaQuery.widthOf(context);

    return Timer.periodic(Duration(milliseconds: 16), (timer) {
      if (stop.value) return;
      if (!treeAni.isAnimating) return;

      for (var i in List.of(objects)) {
        i.x += speed.value.$2;

        if (i.x > width / 2 - 54 && i.x < width / 2 + 54 && !jump.isAnimating) {
          if (i.isCoin) {
            coinA.play();
            appCtrl.coin.value++;
            objects.remove(i);
          } else {
            if (!special) {
              platformM.invokeMethod('vibrate').then((value) {
                print(value);
              });
              treeAni.stop();
              bgA.pause();
              gameOverA.play();
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => GameOverDialog(),
              );
            }
          }
        }

        if (i.x > width + 100) {
          objects.remove(i);
        }
      }
      gameTicker.value = gameTimer!.tick;
    });
  }
}
