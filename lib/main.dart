import 'package:flutter/material.dart';
import 'package:two_zero_four_eight/core/game_state_notifier.dart';
import 'package:two_zero_four_eight/ui/components/grid.dart';
import 'package:two_zero_four_eight/ui/components/score_card.dart';
import 'package:two_zero_four_eight/ui/components/tile.dart';
import 'package:two_zero_four_eight/ui/views/board_view.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider<GameStateNotifier>(
        create: (context) => GameStateNotifier(),
        child: Scaffold(
          body: Center(
              child: Consumer<GameStateNotifier>(
            builder: (context, value, child) => Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "2048",
                          style: TextStyle(fontSize: 40),
                        ),
                        ScoreCard(score: value.score),
                      ],
                    ),
                  ),
                  BoardView(
                    gameState: value,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ElevatedButton(
                        style: ButtonStyle(
                            maximumSize: MaterialStateProperty.all(
                                Size(120, double.infinity)),
                            backgroundColor: MaterialStateProperty.all(
                                Colors.brown.shade300)),
                        onPressed: () {
                          value.init();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                'Restart',
                                style: TextStyle(color: Colors.white),
                              ),
                              Icon(
                                Icons.restart_alt,
                                color: Colors.white,
                              )
                            ],
                          ),
                        )),
                  )
                ],
              ),
            ),
          )),
        ),
      ),
    );
  }
}
