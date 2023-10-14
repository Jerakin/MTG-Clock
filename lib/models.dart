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
  final turnOrder = {
    2: [0, 2, 1],
    3: [0, 2, 3, 1],
    4: [0, 2, 4, 1, 3],
    5: [0, 2, 5, 1, 3, 4],
    6: [0, 2, 5, 6, 3, 4, 1],
  };

  int totalTime() {
    int total = 0;
    for (int i in playerTimers.values) {
      total += i;
    }
    return Duration(milliseconds: total * 100).inSeconds;
  }

  int playerTime(player) {
    int v = playerTimers[player] ?? 0;
    return Duration(milliseconds: v * 100).inSeconds;
  }

  void reset(){
    currentPlayer = 0;
    isPaused = true;
    playerTimers = HashMap();
    notifyListeners();
  }

  void togglePaused() {
    if (currentPlayer == 0) {
      passTurn(1, 1);
    } else {
      isPaused = !isPaused;
      notifyListeners();
    }
  }

  void setActivePlayer(int i) {
    currentPlayer = i;
  }

  String getPlayerTimeString(int i) {
    return formatTimePlayers(playerTimers[i] ?? 0);
  }

  void passTurn(int player, int maxPlayers) {
    if (timer == null) {
      startTimer();
    }
    // Change the player, if the current player is clicked pass it.
    // If another player is clicked, set that player as current.
    if (currentPlayer == player) {
      List<int> turnList = turnOrder[maxPlayers] ?? [];
      int passTo = turnList[player];
      setActivePlayer(passTo);
    } else {
      setActivePlayer(player);
    }
    isPaused = false;
  }

  void startTimer() {
    const oneSec = Duration(milliseconds: 100);
    timer = Timer.periodic(
      oneSec,
      (Timer timer) {
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

  String formatTimeSeconds(value) {
    final duration = Duration(seconds: value);
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  String formatTimePlayers(value) {
    final duration = Duration(milliseconds: value * 100);
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    String milliseconds =
        ((duration.inMilliseconds % 1000) ~/ 10).toString().substring(0, 1);

    return '$minutes:$seconds.$milliseconds';
  }
}

class MyAppSettings extends ChangeNotifier {
  int players = 4;
  static const List<int> player_list = <int>[2, 3, 4, 5, 6];
  List<int> currentTimers = [40, 40, 40];
  int selectedTimer = 3;

  int getTotalTime() {
    if (selectedTimer == 1) {
      return currentTimers[0] * players;
    } else if (selectedTimer == 2) {
      return currentTimers[1];
    } else {
      return 0;
    }
  }

  void setSelectedTimerStyle(int v) {
    selectedTimer = v;
  }

  int maxTimePerPlayer() {
    if (selectedTimer == 1) {
      return currentTimers[0] * players;
    } else if (selectedTimer == 2) {
      return currentTimers[1];
    }
    return 0;
  }

  bool globalTimeReached(currentTotalTime) {
    if (selectedTimer == 1) {
      return currentTimers[0] * players <= currentTotalTime;
    } else if (selectedTimer == 2) {
      return currentTimers[1] <= currentTotalTime;
    }
    return false;
  }
}

bool isFalse(bool value) => (value == false);
