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
      AnimationController(vsync: this, duration: Duration(milliseconds: 150))
        ..forward();
  late final AnimationController _controllerScale =
      AnimationController(vsync: this, duration: Duration(milliseconds: 100));

  late final AnimationController _controllerScaleMerge =
      AnimationController(vsync: this, duration: Duration(milliseconds: 50));

  List<List<int>> mergeCell = [
    for (int i = 0; i < 4; i++) [for (int j = 0; j < 4; j++) 0]
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.isCompleted) {
        _controllerScale.reset();
        _controllerScale.forward();
        _controllerScaleMerge.reset();
        _controllerScaleMerge
            .fling()
            .whenComplete(() => _controllerScaleMerge.reverse());
      }
    });
  }

  Swipe lastSwipe = Swipe.none;

  @override
  void dispose() {
    _controller.dispose();
    _controllerScale.dispose();
    _controllerScaleMerge.dispose();
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
            int flag = 0;
            if (mergeCell[i][j] == 1) {
              flag = 1;
              tiles.add(PositionedTransition(
                rect: RelativeRectTween(
                        begin: RelativeRect.fromSize(
                            Rect.fromLTWH(
                                j * tileSize, i * tileSize, tileSize, tileSize),
                            Size(boardWidth, boardWidth)),
                        end: RelativeRect.fromSize(
                            Rect.fromLTWH(
                                j * tileSize, i * tileSize, tileSize, tileSize),
                            Size(boardWidth, boardWidth)))
                    .animate(CurvedAnimation(
                        parent: _controller, curve: Curves.decelerate)),
                child: Tile(
                    color: Colors.amber,
                    value: (widget.gameState.stateMatrix[i][j] / 2).toInt(),
                    size: tileSize),
              ));
            }
            tiles.add((flag == 0)
                ? PositionedTransition(
                    rect: RelativeRectTween(
                            begin: RelativeRect.fromSize(
                                Rect.fromLTWH(
                                    previousOffset[i][j].dx * tileSize,
                                    previousOffset[i][j].dy * tileSize,
                                    tileSize,
                                    tileSize),
                                Size(boardWidth, boardWidth)),
                            end: RelativeRect.fromSize(
                                Rect.fromLTWH(j * tileSize, i * tileSize,
                                    tileSize, tileSize),
                                Size(boardWidth, boardWidth)))
                        .animate(CurvedAnimation(
                            parent: _controller, curve: Curves.decelerate)),
                    child: Tile(
                        color: Colors.amber,
                        value: widget.gameState.stateMatrix[i][j],
                        size: tileSize),
                  )
                : PositionedTransition(
                    rect: RelativeRectTween(
                            begin: RelativeRect.fromSize(
                                Rect.fromLTWH(
                                    previousOffset[i][j].dx * tileSize,
                                    previousOffset[i][j].dy * tileSize,
                                    tileSize,
                                    tileSize),
                                Size(boardWidth, boardWidth)),
                            end: RelativeRect.fromSize(
                                Rect.fromLTWH(j * tileSize, i * tileSize,
                                    tileSize, tileSize),
                                Size(boardWidth, boardWidth)))
                        .animate(CurvedAnimation(
                            parent: _controller, curve: Curves.decelerate)),
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 1, end: 1.2).animate(
                          CurvedAnimation(
                              parent: _controllerScaleMerge,
                              curve: Curves.bounceInOut)),
                      child: Tile(
                          color: Colors.amber,
                          value: widget.gameState.stateMatrix[i][j],
                          size: tileSize),
                    ),
                  ));
          }
        }
      }
    }

    return tiles;
  }

  List<List<Offset>> _calculateInitialPosition(var current, var previous) {
    List<List<Offset>> x;
    mergeCell = [
      for (int i = 0; i < 4; i++) [for (int j = 0; j < 4; j++) 0]
    ];
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
    mergeCell = List.from([
      for (int i = 0; i < 4; i++) [for (int j = 0; j < 4; j++) mergeCell[j][i]]
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
    mergeCell = List.from([
      for (int i = 0; i < 4; i++) [for (int j = 0; j < 4; j++) mergeCell[j][i]]
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
    mergeCell = List.from([
      for (int i = 0; i < 4; i++) [...mergeCell[i].reversed]
    ]);
    x = List.from([
      for (int i = 0; i < 4; i++)
        [for (int j = 0; j < 4; j++) Offset(3 - x[i][j].dx, x[i][j].dy)]
    ]);
    log(tempCurrent.toString());
    log(tempPrevious.toString());
    log(x.toString());
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
                previous[k][j] = 0;
                break;
              } else {
                //log("merge");
                mergeCell[k][i] = 1;
                int flag = 1;
                for (int l = i; l < 4 && flag < 3; l++) {
                  if (previous[k][l] == current[k][i] / 2) {
                    x[k][i] = Offset(l.toDouble(), k.toDouble());
                    flag++;
                    //log(" $i , $k -> $l $k");

                    if (flag == 3) {
                      previous[k][l] = 0;
                      //log(previous.toString());
                    }
                  }
                }
                break;
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
        if (widget.gameState.gameover) {
          Future.delayed(Duration.zero, () async {
            showDialog(
              barrierColor: Colors.amber.withOpacity(0.5),
              barrierDismissible: false,
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Game Over"),
                alignment: Alignment.center,
                actionsAlignment: MainAxisAlignment.end,
                actions: [
                  ElevatedButton(
                      style: ButtonStyle(
                          maximumSize: MaterialStateProperty.all(
                              Size(120, double.infinity)),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.brown.shade300)),
                      onPressed: () {
                        widget.gameState.init();
                        Navigator.of(context).pop();
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
                      ))
                ],
              ),
            );
          });
        }
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
