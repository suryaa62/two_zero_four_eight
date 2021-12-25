import 'package:flutter/material.dart';
import 'package:two_zero_four_eight/core/game_state_notifier.dart';
import 'package:two_zero_four_eight/ui/components/grid.dart';
import 'package:two_zero_four_eight/ui/components/tile.dart';

class BoardView extends StatelessWidget {
  const BoardView({Key? key, required this.gameState}) : super(key: key);
  final GameStateNotifier gameState;

  List<Positioned> _layoutTile(double boardWidth) {
    double tileSize = boardWidth / gameState.gridsize;
    List<Positioned> tiles = [];
    for (int i = 0; i < gameState.gridsize; i++) {
      for (int j = 0; j < gameState.gridsize; j++) {
        if (gameState.stateMatrix[i][j] != 0) {
          tiles.add(Positioned(
            top: i * tileSize,
            left: j * tileSize,
            child: Tile(
                color: Colors.amber,
                value: gameState.stateMatrix[i][j],
                size: tileSize),
          ));
        }
      }
    }
    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    Swipe swipe = Swipe.none;
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            int senstivity = 8;
            if (details.delta.dx > senstivity) {
              swipe = Swipe.right;
            } else if (details.delta.dx < -senstivity) {
              swipe = Swipe.left;
            }
          },
          onHorizontalDragEnd: (details) {
            if (swipe == Swipe.right)
              gameState.swipeRight();
            else if (swipe == Swipe.left) gameState.swipeLeft();
          },
          onVerticalDragUpdate: (details) {
            int senstivity = 8;
            if (details.delta.dy > senstivity) {
              swipe = Swipe.down;
            } else if (details.delta.dy < -senstivity) {
              swipe = Swipe.up;
            }
          },
          onVerticalDragEnd: (details) {
            if (swipe == Swipe.up)
              gameState.swipeUp();
            else if (swipe == Swipe.down) gameState.swipeDown();
          },
          child: Stack(
            children: [
              Grid(),
              ..._layoutTile(constraints.maxWidth),
            ],
          ),
        );
      },
    );
  }
}

enum Swipe {
  left,
  right,
  up,
  down,
  none,
}
