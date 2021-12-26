import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/foundation.dart';

import 'package:flutter/cupertino.dart';

class GameStateNotifier extends ChangeNotifier {
  GameStateNotifier({this.gridsize = 4}) {
    _stateMatrix = [
      for (int i = 0; i < gridsize; i++) [for (int j = 0; j < gridsize; j++) 0]
    ];
    // _stateMatrix = [
    //   [0, 0, 0, 0],
    //   [2, 4, 4, 4],
    //   [8, 2, 0, 2],
    //   [2, 256, 128, 128]
    // ];
    _oldStateMatrix = [
      for (int i = 0; i < gridsize; i++) [..._stateMatrix[i]]
    ];
    _fillRandom();
    _fillRandom();
  }

  int gridsize;
  late List<List<int>> _stateMatrix;
  late List<List<int>> _oldStateMatrix;
  Random random = Random();
  Offset newTile = Offset.zero;

  List<List<int>> get stateMatrix => _stateMatrix;
  List<List<int>> get oldStateMatrix => _oldStateMatrix;

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

    for (int i = 0; i < gridsize; i++) {
      if (!listEquals(_oldStateMatrix[i], _stateMatrix[i])) {
        // dev.log(true.toString());
        _fillRandom();
        notifyListeners();
        break;
      }
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
