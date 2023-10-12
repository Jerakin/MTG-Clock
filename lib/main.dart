import 'dart:collection';
import 'dart:html';
import 'dart:js_util';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:numberpicker/numberpicker.dart';
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

}

class _HomeScreenState extends State<HomeScreen> {
  int currentScreenIndex = 0;
  late Widget currentWidget;

  @override
  Widget build(BuildContext context) {
    switch (currentScreenIndex) {
      case 0:
        currentWidget = const TimerScreen();
      case 1:
        currentWidget = const SettingsScreen();
      default:
        throw UnimplementedError();
    }

    return Scaffold(
      body: currentWidget,
      floatingActionButton:
      Consumer<MyAppModel>(
        builder: (context, appModel, child) {
          return Visibility(
            visible: appModel.isPaused,
            child: FloatingActionButton(
              onPressed: (){
                setState(() {
                  currentScreenIndex = 1 - currentScreenIndex;
                });
              },
              child: currentScreenIndex == 0 ? const Icon(Icons.settings) : const Icon(Icons.arrow_forward_rounded),
            )
          );
        }
      )
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _player = 4;
  static const List<int> _list = <int>[2, 3, 4, 5, 6];
  List<bool> isSelected = [true, false, false];
  List<int> _currentTimers = [40, 40, 40];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        // constraints: const BoxConstraints(maxWidth: 400),
        child: ListView(
          children: [
            _SingleSection(
              title: "General",
              children: [
                _CustomListTile(
                    title: "Players",
                    icon: Icons.people,
                    trailing: DropdownButton<int>(
                      value: _player,
                      onChanged: (int? value) {
                        // This is called when the user selects an item.
                        setState(() {
                          _player = value!;
                        });
                      },
                      items: _list.map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                    )
                ),
              ],
            ),
            const Divider(),
            _SingleSection(
              title: "Timer styles",
              children: [
                _CustomListTile(
                  title: "Per Player",
                  icon: Icons.person,
                  trailing: Switch(
                  value: isSelected[0],
                  onChanged: (value) {
                    setState(() {
                      for (int index = 0; index < isSelected.length; index++) {
                        if (index == 0) {
                          // toggling between the button to set it to true
                          isSelected[index] = !isSelected[index];
                        } else {
                          // other two buttons will not be selected and are set to false
                          isSelected[index] = false;
                        }
                      }
                      if (isSelected.every(isFalse)){
                        isSelected[0] = true;
                      }
                    });
                  })
                ),
                Visibility(
                    visible: isSelected[0],
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                      }),
                      child: NumberPicker(
                        selectedTextStyle: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0),
                        textStyle: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.0),
                        value: _currentTimers[0],
                        axis: Axis.horizontal,
                        itemCount: 5,
                        minValue: 10,
                        maxValue: 240,
                        step: 5,
                        onChanged: (value) {
                          setState(() {
                            _currentTimers[0] = value;
                          });
                        },
                      ),
                    )
                ),
                _CustomListTile(
                  title: "Total Time",
                  icon: Icons.watch_later_outlined,
                  trailing: Switch(
                    value: isSelected[1],
                    onChanged: (value) {
                      setState(() {
                        for (int index = 0; index < isSelected.length; index++) {
                          if (index == 1) {
                            // toggling between the button to set it to true
                            isSelected[index] = !isSelected[index];
                          } else {
                            // other two buttons will not be selected and are set to false
                            isSelected[index] = false;
                          }
                        }
                        if (isSelected.every(isFalse)){
                          isSelected[1] = true;
                        }
                      });
                    })
                ),
                Visibility(
                  visible: isSelected[1],
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    }),
                    child: NumberPicker(
                      selectedTextStyle: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0),
                      textStyle: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.0),
                      value: _currentTimers[1],
                      axis: Axis.horizontal,
                      itemCount: 5,
                      minValue: 10,
                      maxValue: 240,
                      step: 5,
                      onChanged: (value) {
                        setState(() {
                          _currentTimers[1] = value;
                        });
                      },
                    ),
                  )
                ),
                _CustomListTile(
                  title: "Stopwatch",
                  icon: Icons.timer_sharp,
                  trailing: Switch(
                    value: isSelected[2],
                    onChanged: (value) {
                      setState(() {
                        for (int index = 0; index < isSelected.length; index++) {
                          if (index == 2) {
                            // toggling between the button to set it to true
                            isSelected[index] = !isSelected[index];
                          } else {
                            // other two buttons will not be selected and are set to false
                            isSelected[index] = false;
                          }
                        }
                        if (isSelected.every(isFalse)){
                          isSelected[2] = true;
                        }
                      });
                    })
                ),
              ],
            ),
            const Divider(),
            const _SingleSection(
              children: [
                _CustomListTile(
                    title: "Help & Feedback",
                    icon: Icons.help_outline_rounded),
                _CustomListTile(
                    title: "About", icon: Icons.info_outline_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class _CustomListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  const _CustomListTile(
      {Key? key, required this.title, required this.icon, this.trailing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      trailing: trailing,
      onTap: () {},
    );
  }
}

class _SingleSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  const _SingleSection({
    Key? key,
    this.title,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        Column(
          children: children,
        ),
      ],
    );
  }
}

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

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

bool isFalse(bool value) => (value == false);

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