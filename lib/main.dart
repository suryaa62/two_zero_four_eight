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

  // This widget is the root of your application.
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
                  ScoreCard(score: 155),
                  BoardView(
                    gameState: value,
                  ),
                ],
              ),
            ),
          )),
        ),
      ),
    );
  }
}
