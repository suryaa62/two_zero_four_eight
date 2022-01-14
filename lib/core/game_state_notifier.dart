import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/foundation.dart';

import 'package:flutter/cupertino.dart';

class GameStateNotifier extends ChangeNotifier {
  GameStateNotifier({this.gridsize = 4}) {
    init();
  }

  int gridsize;
  late List<List<int>> _stateMatrix;
  late List<List<int>> _oldStateMatrix;
  Random random = Random();
  Offset newTile = Offset.zero;
  late int score;
  bool gameover = false;

  List<List<int>> get stateMatrix => _stateMatrix;
  List<List<int>> get oldStateMatrix => _oldStateMatrix;

  void init() {
    _stateMatrix = [
      for (int i = 0; i < gridsize; i++) [for (int j = 0; j < gridsize; j++) 0]
    ];
    // _stateMatrix = [
    //   [1, 2, 3, 4],
    //   [4, 3, 2, 1],
    //   [1, 2, 3, 4],
    //   [0, 0, 0, 0]
    // ];
    _oldStateMatrix = [
      for (int i = 0; i < gridsize; i++) [..._stateMatrix[i]]
    ];
    score = 0;
    gameover = false;
    _fillRandom();
    _fillRandom();
    notifyListeners();
  }

  int _twoOrFour() {
    double x = random.nextDouble();
    if (x < 0.2) return 4;
    return 2;
  }

  void _fillRandom() {
    int x = random.nextInt(gridsize * gridsize);
    int i = (x / gridsize).floor();
    int j = x % gridsize;
    if (_stateMatrix[i][j] == 0) {
      _stateMatrix[i][j] = _twoOrFour();
      newTile = Offset(j.toDouble(), i.toDouble());
    } else {
      _fillRandom();
    }
  }

  void _shift(List<int> l) {
    int tempindex = -1;
    for (int i = 0; i <= gridsize - 1; i++) {
      if (l[i] != 0 && tempindex == -1) continue;
      if (l[i] != 0 && tempindex != -1) {
        l[tempindex] = l[i];
        l[i] = 0;
        tempindex = -1;
        for (int j = 0; j <= i; j++) {
          if (l[j] == 0) {
            tempindex = j;
            break;
          }
        }
        continue;
      }
      if (l[i] == 0 && tempindex == -1) tempindex = i;
    }
  }

  void _merge(List<int> l) {
    for (int i = 0; i < gridsize - 1; i++) {
      if (l[i] == l[i + 1]) {
        l[i] += l[i + 1];
        l[i + 1] = 0;
        score += l[i];
      }
    }
  }

  void _swipe(List<int> l) {
    _shift(l);
    _merge(l);
    _shift(l);
  }

  void _preSwipeOperation() {
    _oldStateMatrix = [
      for (int i = 0; i < gridsize; i++) [..._stateMatrix[i]]
    ];
  }

  void _postSwipeOperation() {
    // print(_oldStateMatrix);
    // print(_stateMatrix);
    bool diff = false;
    for (int i = 0; i < gridsize; i++) {
      if (!listEquals(_oldStateMatrix[i], _stateMatrix[i])) {
        // dev.log(true.toString());
        diff = true;
        _fillRandom();
        notifyListeners();
        break;
      }
    }
    if (!diff) {
      for (int i = 0; i < gridsize; i++) {
        if (_stateMatrix[i].contains(0)) {
          break;
        }
        if (i == gridsize - 1) {
          gameover = true;
          for (int j = 0; j < gridsize; j++) {
            if (gameover == false) break;
            for (int k = 0; k < gridsize - 1; k++) {
              if (_stateMatrix[j][k] == _stateMatrix[j][k + 1] ||
                  _stateMatrix[k][j] == _stateMatrix[k + 1][j]) {
                gameover = false;
                break;
              }
            }
          }
        }
      }
      if (gameover) notifyListeners();
    }
  }

  void swipeLeft() {
    _preSwipeOperation();
    for (int i = 0; i <= gridsize - 1; i++) {
      _swipe(_stateMatrix[i]);
    }
    _postSwipeOperation();
  }

  void swipeRight() {
    _preSwipeOperation();
    for (int i = 0; i <= gridsize - 1; i++) {
      List<int> l = List.from(_stateMatrix[i].reversed);
      _swipe(l);
      _stateMatrix[i] = List.from(l.reversed);
    }
    _postSwipeOperation();
  }

  void swipeUp() {
    _preSwipeOperation();
    for (int i = 0; i <= gridsize - 1; i++) {
      List<int> l = [];
      for (int j = 0; j <= gridsize - 1; j++) {
        l.add(_stateMatrix[j][i]);
      }

      _swipe(l);

      for (int j = 0; j <= gridsize - 1; j++) {
        _stateMatrix[j][i] = l[j];
      }
      // dev.log(_oldStateMatrix.toString());
      // dev.log(_stateMatrix.toString());
    }
    _postSwipeOperation();
  }

  void swipeDown() {
    _preSwipeOperation();
    for (int i = 0; i <= gridsize - 1; i++) {
      List<int> l = [];
      for (int j = gridsize - 1; j >= 0; j--) {
        l.add(_stateMatrix[j][i]);
      }

      _swipe(l);

      l = List.from(l.reversed);
      for (int j = gridsize - 1; j >= 0; j--) {
        _stateMatrix[j][i] = l[j];
      }
    }
    _postSwipeOperation();
  }
}
