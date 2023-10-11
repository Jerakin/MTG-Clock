import 'dart:collection';
import 'dart:html';
import 'dart:js_util';
import 'dart:async';
import 'dart:math';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Super Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(title: 'EDH Timer'),
    );
  }
}

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class MyAppState extends ChangeNotifier {
  bool isPaused = true;
}


class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TimerScreen(),
      floatingActionButton:
        Visibility(
          visible: false,
          child: FloatingActionButton(
            onPressed: (){},
            child: const Icon(Icons.settings),
          )),
    );
  }
}

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Map<int, int> playerTimers = HashMap();
  int _currentPlayer = 0;
  Timer? _timer;
  static const double _widgetMargin = 8;

  void _startTimer() {
    const oneSec = Duration(milliseconds: 100);
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) {
        setState(() {
          // Add a second to the current player
          int current = playerTimers.putIfAbsent(_currentPlayer, () => 0);
          playerTimers.update(_currentPlayer, (value) => current + 1);
        });
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

  void _pause(){
    setState(() {
      _currentPlayer = 0;
    });
  }

  void _passTurn(int player){
    setState(() {
      if (_timer == null){
        // If no timer has been started it's a new game, set clicked player
        //  as active and start the timer
        _currentPlayer = player;
        _startTimer();
        return;
      }

      // Change the player, if the current player is clicked pass it.
      // If another player is clicked, set that player as current.
      if (_currentPlayer == player) {
        _currentPlayer = modulo(_currentPlayer, 4) + 1;
      } else {
        _currentPlayer = player;
      }
    });
  }

  Expanded _playerIndicator(playerNum) {
    return  Expanded(
      child: InkWell(
        child: Container(
          decoration: playerButtonDecoration(playerNum, _currentPlayer),
          child: Center(
            child: Text(
              _toTime(playerTimers[playerNum] ?? 0),
              style:Theme.of(context).textTheme.headlineLarge,
            ),
          ),
        ),
        onTap: () => _passTurn(playerNum),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double pauseButtonDiameter = min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.33;
    var appState = context.watch<MyAppState>();

    return Center(
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _playerIndicator(1),
                    const SizedBox(height: _widgetMargin), // Margin
                    _playerIndicator(4),
                  ],
                ),
              ),
              const SizedBox(width: _widgetMargin), // Margin
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _playerIndicator(2),
                    const SizedBox(height: _widgetMargin), // Margin
                    _playerIndicator(3),
                  ],
                ),
              ),
            ],
        ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: pauseButtonDiameter+_widgetMargin*2,
              height: pauseButtonDiameter+_widgetMargin*2,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () => {appState.isPaused = !appState.isPaused},
              style: ElevatedButton.styleFrom(
                fixedSize: Size(pauseButtonDiameter, pauseButtonDiameter),
                shape: const CircleBorder(),
              ),
              child: Icon(Icons.pause_sharp, color: Colors.white, size: pauseButtonDiameter*0.4,),
            ),
          ),
        ],
      ),
    );
  }
}



EdgeInsets playerButtonEdge(thisPlayer) {
  return EdgeInsets.only(
      left: [1, 4].contains(thisPlayer) ? 0 : 4,
      right: [2, 3].contains(thisPlayer) ? 0 : 4,
      top: [1, 2].contains(thisPlayer) ? 0 : 4,
      bottom: [3, 4].contains(thisPlayer) ? 0 : 4
  );
}

BoxDecoration playerButtonDecoration(thisPlayer, currentPlayer) {
  Color colorActive = Colors.white24;
  Color colorInactive = Colors.black12;

  return BoxDecoration(
    color: thisPlayer == currentPlayer ? colorActive : colorInactive,
  );
}