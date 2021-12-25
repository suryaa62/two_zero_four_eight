import 'package:flutter/cupertino.dart';

class GameStateNotifier extends ChangeNotifier {
  GameStateNotifier({this.gridsize = 4}) {
    _stateMatrix = [
      for (int i = 0; i < gridsize; i++) [for (int j = 0; j < gridsize; j++) 0]
    ];
  }

  int gridsize;
  late List<List<int>> _stateMatrix;

  List<List<int>> get stateMatrix => _stateMatrix;

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

  void swipeLeft() {
    for (int i = 0; i <= gridsize - 1; i++) {
      _swipe(_stateMatrix[i]);
    }
    notifyListeners();
  }

  void swipeRight() {
    for (int i = 0; i <= gridsize - 1; i++) {
      List<int> l = List.from(_stateMatrix[i].reversed);
      _swipe(l);
      _stateMatrix[i] = List.from(l.reversed);
    }
    notifyListeners();
  }

  void swipeUp() {
    for (int i = 0; i <= gridsize - 1; i++) {
      List<int> l = [];
      for (int j = 0; j <= gridsize - 1; j++) {
        l.add(_stateMatrix[j][i]);
      }

      _swipe(l);

      for (int j = 0; j <= gridsize - 1; j++) {
        _stateMatrix[j][i] = l[j];
      }
    }
    notifyListeners();
  }

  void swipeDown() {
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
    notifyListeners();
  }
}
