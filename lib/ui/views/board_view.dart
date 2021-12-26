import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:two_zero_four_eight/core/game_state_notifier.dart';
import 'package:two_zero_four_eight/ui/components/grid.dart';
import 'package:two_zero_four_eight/ui/components/tile.dart';

class BoardView extends StatefulWidget {
  const BoardView({Key? key, required this.gameState}) : super(key: key);
  final GameStateNotifier gameState;

  @override
  State<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> with TickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: Duration(milliseconds: 8000))
        ..forward();
  late final AnimationController _controllerScale =
      AnimationController(vsync: this, duration: Duration(milliseconds: 8000));

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.isCompleted) {
        _controllerScale.reset();
        _controllerScale.forward();
      }
    });
  }

  Swipe lastSwipe = Swipe.none;

  @override
  void dispose() {
    _controller.dispose();
    _controller.dispose();
    super.dispose();
  }

  List<PositionedTransition> _layoutTile(double boardWidth) {
    _controllerScale.reset();
    double tileSize = boardWidth / widget.gameState.gridsize;
    List<PositionedTransition> tiles = [];
    List<List<Offset>> previousOffset = _calculateInitialPosition(
        widget.gameState.stateMatrix, widget.gameState.oldStateMatrix);
    for (int i = 0; i < widget.gameState.gridsize; i++) {
      for (int j = 0; j < widget.gameState.gridsize; j++) {
        if (widget.gameState.stateMatrix[i][j] != 0) {
          if (widget.gameState.newTile.dx == j &&
              widget.gameState.newTile.dy == i) {
            tiles.add(PositionedTransition(
              rect: RelativeRectTween(
                      begin: RelativeRect.fromSize(
                          Rect.fromLTWH(
                              previousOffset[i][j].dx * tileSize + tileSize / 2,
                              previousOffset[i][j].dy * tileSize + tileSize / 2,
                              0,
                              0),
                          Size(boardWidth, boardWidth)),
                      end: RelativeRect.fromSize(
                          Rect.fromLTWH(
                              j * tileSize, i * tileSize, tileSize, tileSize),
                          Size(boardWidth, boardWidth)))
                  .animate(CurvedAnimation(
                      parent: _controllerScale, curve: Curves.easeOut)),
              child: Tile(
                  color: Colors.amber,
                  value: widget.gameState.stateMatrix[i][j],
                  size: tileSize),
            ));
          } else {
            tiles.add(PositionedTransition(
              rect: RelativeRectTween(
                      begin: RelativeRect.fromSize(
                          Rect.fromLTWH(
                              previousOffset[i][j].dx * tileSize,
                              previousOffset[i][j].dy * tileSize,
                              tileSize,
                              tileSize),
                          Size(boardWidth, boardWidth)),
                      end: RelativeRect.fromSize(
                          Rect.fromLTWH(
                              j * tileSize, i * tileSize, tileSize, tileSize),
                          Size(boardWidth, boardWidth)))
                  .animate(CurvedAnimation(
                      parent: _controller, curve: Curves.easeOut)),
              child: Tile(
                  color: Colors.amber,
                  value: widget.gameState.stateMatrix[i][j],
                  size: tileSize),
            ));
          }
        }
      }
    }

    return tiles;
  }

  List<List<Offset>> _calculateInitialPosition(var current, var previous) {
    List<List<Offset>> x;
    if (lastSwipe == Swipe.left) {
      x = _calculateInitialPositionIfSwipeLeft(current, previous);
    } else if (lastSwipe == Swipe.right) {
      x = _calculateInitialPositionIfSwipeRight(current, previous);
    } else if (lastSwipe == Swipe.up) {
      x = _calculateInitialPositionIfSwipeUp(current, previous);
    } else if (lastSwipe == Swipe.down) {
      x = _calculateInitialPositionIfSwipeDown(current, previous);
    } else {
      x = _calculateInitialPositionIfSwipeLeft(current, previous);
    }
    x[widget.gameState.newTile.dy.toInt()]
        [widget.gameState.newTile.dx.toInt()] = widget.gameState.newTile;
    return x;
  }

  List<List<Offset>> _calculateInitialPositionIfSwipeDown(
      var current, var previous) {
    List<List<Offset>> x;
    var tempCurrent = List.from([
      for (int i = 0; i < 4; i++) [for (int j = 0; j < 4; j++) current[j][i]]
    ]);
    var tempPrevious = List.from([
      for (int i = 0; i < 4; i++) [for (int j = 0; j < 4; j++) previous[j][i]]
    ]);
    x = _calculateInitialPositionIfSwipeRight(tempCurrent, tempPrevious);
    x = List.from([
      for (int i = 0; i < 4; i++) [for (int j = 0; j < 4; j++) x[j][i]]
    ]);
    x = List.from([
      for (int i = 0; i < 4; i++)
        [for (int j = 0; j < 4; j++) Offset(x[i][j].dy, x[i][j].dx)]
    ]);
    log(x.toString());
    return x;
  }

  List<List<Offset>> _calculateInitialPositionIfSwipeUp(
      var current, var previous) {
    List<List<Offset>> x;
    var tempCurrent = List.from([
      for (int i = 0; i < 4; i++) [for (int j = 0; j < 4; j++) current[j][i]]
    ]);
    var tempPrevious = List.from([
      for (int i = 0; i < 4; i++) [for (int j = 0; j < 4; j++) previous[j][i]]
    ]);
    x = _calculateInitialPositionIfSwipeLeft(tempCurrent, tempPrevious);
    x = List.from([
      for (int i = 0; i < 4; i++) [for (int j = 0; j < 4; j++) x[j][i]]
    ]);
    x = List.from([
      for (int i = 0; i < 4; i++)
        [for (int j = 0; j < 4; j++) Offset(x[i][j].dy, x[i][j].dx)]
    ]);
    log(tempCurrent.toString());
    log(tempPrevious.toString());
    log(x.toString());
    return x;
  }

  List<List<Offset>> _calculateInitialPositionIfSwipeRight(
      var current, var previous) {
    List<List<Offset>> x;
    var tempCurrent = List.from([
      for (int i = 0; i < 4; i++) [...current[i].reversed]
    ]);
    var tempPrevious = List.from([
      for (int i = 0; i < 4; i++) [...previous[i].reversed]
    ]);
    // log(tempCurrent.toString());

    // log(tempPrevious.toString());
    x = _calculateInitialPositionIfSwipeLeft(tempCurrent, tempPrevious);

    x = List.from([
      for (int i = 0; i < 4; i++) [...x[i].reversed]
    ]);
    x = List.from([
      for (int i = 0; i < 4; i++)
        [for (int j = 0; j < 4; j++) Offset(3 - x[i][j].dx, x[i][j].dy)]
    ]);

    return x;
  }

  List<List<Offset>> _calculateInitialPositionIfSwipeLeft(
      var current, var previous) {
    List<List<Offset>> x = [
      for (int i = 0; i < 4; i++) [for (int j = 0; j < 4; j++) Offset(0, 0)]
    ];
    for (int k = 0; k < 4; k++) {
      for (int i = 0; i < 4; i++) {
        if (current[k][i] == 0) {
          x[k][i] = Offset.zero;
        } else if (previous[k][i] == current[k][i]) {
          x[k][i] = Offset(i.toDouble(), k.toDouble());
        } else {
          for (int j = i + 1; j < 4; j++) {
            if (previous[k][j] != 0) {
              if (previous[k][j] == current[k][i]) {
                x[k][i] = Offset(j.toDouble(), k.toDouble());
              }
            }
          }
        }
      }
    }
    return x;
  }

  @override
  void didUpdateWidget(BoardView board) {
    _controller.reset();
    _controller.forward();
    super.didUpdateWidget(board);
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
            if (swipe == Swipe.right) {
              lastSwipe = Swipe.right;
              widget.gameState.swipeRight();
            } else if (swipe == Swipe.left) {
              widget.gameState.swipeLeft();
              lastSwipe = Swipe.left;
            }
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
            if (swipe == Swipe.up) {
              widget.gameState.swipeUp();
              lastSwipe = Swipe.up;
            } else if (swipe == Swipe.down) {
              widget.gameState.swipeDown();
              lastSwipe = Swipe.down;
            }
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
