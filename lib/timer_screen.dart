import 'dart:collection';
import 'dart:html';
import 'dart:js_util';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:numberpicker/numberpicker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/models.dart';

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