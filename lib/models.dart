import 'dart:collection';
import 'dart:async';
import 'package:flutter/material.dart';

import '/simple_prefs.dart';

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

  Duration totalTime() {
    int total = 0;
    for (int i in playerTimers.values) {
      total += i;
    }
    return Duration(milliseconds: total * 100);
  }

  Duration playerTime(player) {
    int v = playerTimers[player] ?? 0;
    return Duration(milliseconds: v * 100);
  }

  void reset() {
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

  String getPlayerTimeString(int player) {
    return getFormattedTime(playerTime(player), includeMilliseconds:true);
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

  String getFormattedTime(duration, {includeMilliseconds = false}) {
    String outMin = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String outSeconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    String milliseconds =
        ((duration.inMilliseconds % 1000) ~/ 10).toString().substring(0, 1);
    if (includeMilliseconds){
      return '$outMin:$outSeconds.$milliseconds';
    }
    return '$outMin:$outSeconds';
  }
}

class MyAppSettings extends ChangeNotifier {
  int playerCount = SimplePrefs.getPlayerCount() ?? 4;
  int selectedTimer = SimplePrefs.getSelectedTimer() ?? 2;
  Duration playerTimeLimit = Duration(minutes: SimplePrefs.getPerPlayerTimeLimit() ?? 20);
  Duration tournamentTimeLimit = Duration(minutes: SimplePrefs.getTournamentTimeLimit() ?? 90);

  Future<void> setPlayerTimeLimit(int time) async {
    playerTimeLimit = Duration(minutes: time);
    SimplePrefs.setPerPlayerTimeLimit(time);
  }

  Future<void> setTournamentTimeLimit(int time) async {
    tournamentTimeLimit = Duration(minutes: time);
    SimplePrefs.setTournamentTimeLimit(time);
  }

  Future<void> setPlayerCount(int value) async {
    playerCount = value;
    SimplePrefs.setPlayerCount(value);
  }

  Future<void> setSelectedTimerStyle(int v) async {
    selectedTimer = v;
    SimplePrefs.setSelectedTimer(v);
  }

  Duration getTotalTime() {
    if (selectedTimer == 1) {
      return playerTimeLimit * playerCount;
    } else if (selectedTimer == 2) {
      return tournamentTimeLimit;
    } else {
      return const Duration();
    }
  }

  bool globalTimeReached(Duration currentTotalTime) {
    if (selectedTimer == 1) {
      return playerTimeLimit * playerCount <= currentTotalTime;
    } else if (selectedTimer == 2) {
      return tournamentTimeLimit <= currentTotalTime;
    }
    return false;
  }
}

bool isFalse(bool value) => (value == false);
