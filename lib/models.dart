import 'dart:collection';
import 'dart:html';
import 'dart:js_util';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:numberpicker/numberpicker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyAppModel extends ChangeNotifier {
  Map<int, int> playerTimers = HashMap();
  int currentPlayer = 0;
  Timer? timer;
  bool isPaused = true;

  void togglePaused(){
    if (currentPlayer == 0){
      return;
    }
    isPaused = !isPaused;
    notifyListeners();
  }

  void setActivePlayer(int i){
    currentPlayer = i;
  }

  String getPlayerTimeString(int i){
    return _toTime(playerTimers[i] ?? 0);
  }

  void passTurn(int player){
    if (timer == null){
      startTimer();
    }
    // Change the player, if the current player is clicked pass it.
    // If another player is clicked, set that player as current.
    if (currentPlayer == player) {
      setActivePlayer(modulo(currentPlayer, 4) + 1);
    } else {
      setActivePlayer(player);
    }
    isPaused = false;
  }

  void startTimer() {
    const oneSec = Duration(milliseconds: 100);
    timer = Timer.periodic(
      oneSec, (Timer timer) {
      if (isPaused) {
        return;
      }

      // Add a second to the current player
      int current = playerTimers.putIfAbsent(currentPlayer, () => 0);
      playerTimers.update(currentPlayer, (value) => current + 1);

      // We don't need to notify our listeners when we pass turn as this is
      // called every 100ms. I wonder if we should refactor the timer into
      // it's own state that updates only the text?
      notifyListeners();
    },
    );
  }

  String _toTime(value){
    final duration = Duration(milliseconds: value*100);
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    String milliseconds = ((duration.inMilliseconds % 1000) ~/ 10).toString().substring(0, 1);

    return '$minutes:$seconds.$milliseconds';
  }
}

class MyAppSettings extends ChangeNotifier {
  int players = 4;
  static const List<int> player_list = <int>[2, 3, 4, 5, 6];
  List<bool> isSelected = [true, false, false];
  List<int> currentTimers = [40, 40, 40];

  void setSelectedTimerStyle(v){
    for (int index = 0; index < isSelected.length; index++) {
      if (index == v) {
        // toggling between the button to set it to true
        isSelected[index] = !isSelected[index];
      } else {
        // other two buttons will not be selected and are set to false
        isSelected[index] = false;
      }
    }
    if (isSelected.every(isFalse)){
      isSelected[v] = true;
    }
  }

  int maxTimePerPlayer(){
    if (isSelected[0]){
      return currentTimers[0]*players;
    }
    else if (isSelected[1]){
      return currentTimers[1];
    }
    return 0;
  }

  bool globalTimeReached(currentTotalTime){
    if (isSelected[0]){
      return currentTimers[0]*players <= currentTotalTime;
    }
    else if (isSelected[1]){
      return currentTimers[1] <= currentTotalTime;
    }
    return false;
  }
}
bool isFalse(bool value) => (value == false);
