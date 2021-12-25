import 'package:flutter/material.dart';
import 'package:two_zero_four_eight/core/game_state_notifier.dart';
import 'package:two_zero_four_eight/ui/components/grid.dart';
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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider<GameStateNotifier>(
        create: (context) => GameStateNotifier(),
        child: Scaffold(
          body: Center(
              child: Consumer<GameStateNotifier>(
            builder: (context, value, child) => Padding(
              padding: const EdgeInsets.all(40),
              child: BoardView(
                gameState: value,
              ),
            ),
          )),
        ),
      ),
    );
  }
}
