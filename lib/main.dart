import 'dart:collection';
import 'dart:html';
import 'dart:js_util';
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      home: MultiProvider(
         providers: [
           ChangeNotifierProvider(create: (context) => MyAppModel()),
           ChangeNotifierProvider(create: (context) => MyAppSettings())
         ],
          child:const HomeScreen(title: 'EDH Timer')),
    );
  }
}

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

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

        // We don't need to notify our listeners about our state more than here
        // as this is called every 100ms. I wonder if we should refactor the
        // timer into it's own state that updates only the text?
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

}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TimerScreen(),
      floatingActionButton:
      Consumer<MyAppModel>(
        builder: (context, appModel, child) {
          return Visibility(
            visible: appModel.isPaused,
            child: FloatingActionButton(
              onPressed: (){},
              child: const Icon(Icons.settings),
            )
          );
        }
      )
    );
  }
}


class TimerScreen extends StatelessWidget {
  static const double _widgetMargin = 8;

  Expanded _playerIndicator(BuildContext context, MyAppModel appModel, playerNum) {
    return  Expanded(
      child: InkWell(
        child: Container(
          decoration: playerButtonDecoration(playerNum, appModel.currentPlayer),
          child: Center(
            child: Text(
              appModel.getPlayerTimeString(playerNum),
              style:Theme.of(context).textTheme.headlineLarge,
            ),
          ),
        ),
        onTap: () => appModel.passTurn(playerNum),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double pauseButtonDiameter = min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.33;

    return Center(
      child: Stack(
        children: [
          Consumer<MyAppModel>(
              builder: (context, appModel, child) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _playerIndicator(context, appModel, 1),
                          const SizedBox(height: _widgetMargin), // Margin
                          _playerIndicator(context, appModel, 4),
                        ],
                      ),
                    ),
                    const SizedBox(width: _widgetMargin), // Margin
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _playerIndicator(context, appModel, 2),
                          const SizedBox(height: _widgetMargin), // Margin
                          _playerIndicator(context, appModel, 3),
                        ],
                      ),
                    ),
                  ],
                );
              }),
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
              onPressed: () => {
                Provider.of<MyAppModel>(context, listen: false).togglePaused()
              },
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