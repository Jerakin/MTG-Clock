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

  Expanded _playerIndicator(BuildContext context, MyAppModel appModel,
      MyAppSettings appSettings, playerNum) {
    int quarterTurns = 0;
    if (playerNum == 1) {
      quarterTurns = 2;
      if (appSettings.playerCount < 3) {
        quarterTurns = 1;
      }
    } else if (playerNum == 2) {
      quarterTurns = 2;
      if (appSettings.playerCount < 4) {
        quarterTurns = 3;
      }
    } else if (playerNum == 5) {
      quarterTurns = 3;
    } else if (playerNum == 6) {
      quarterTurns = 1;
    }

    return Expanded(
      child: InkWell(
        child: Container(
          decoration: playerButtonDecoration(
              context, playerNum, appModel.currentPlayer),
          child: Center(
              child: RotatedBox(
            quarterTurns: quarterTurns,
            child: Text(
              appModel.getPlayerTimeString(playerNum),
              style: playerTextStyle(context, appModel, appSettings, playerNum),
            ),
          )),
        ),
        onTap: () => appModel.passTurn(playerNum, appSettings.playerCount),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double pauseButtonDiameter =
        min(MediaQuery.of(context).size.height, screenWidth) * 0.33;

    return Center(
      child: Stack(
        children: [
          Consumer2<MyAppModel, MyAppSettings>(
              builder: (context, appModel, appSettings, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Stack(children: [
                  const SizedBox(
                    height: _widgetMargin * 4,
                  ),
                  Align(
                      alignment: Alignment.topLeft,
                      child: Visibility(
                        visible: appSettings.selectedTimer != 3,
                        child: SizedBox(
                          height: _widgetMargin * 4,
                          width: screenWidth *
                              (appModel.totalTime() /
                                  appSettings.getTotalTime()),
                          child: DecoratedBox(
                              decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                          )),
                        ),
                      )),
                  Center(
                      child: Text(
                    appModel.formatTimeSeconds(appModel.totalTime()),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ))
                ]), // Margin
                Expanded(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Visibility(
                          visible: appSettings.playerCount > 5,
                          child: _playerIndicator(
                              context, appModel, appSettings, 6),
                        ),
                        Visibility(
                          visible: appSettings.playerCount > 5,
                          child: const SizedBox(width: _widgetMargin),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              _playerIndicator(
                                  context, appModel, appSettings, 1),
                              Visibility(
                                visible: appSettings.playerCount > 2,
                                child: const SizedBox(height: _widgetMargin),
                              ),
                              Visibility(
                                visible: appSettings.playerCount > 2,
                                child: _playerIndicator(
                                    context, appModel, appSettings, 3),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: _widgetMargin),
                        Visibility(
                          visible: appSettings.playerCount > 1,
                          child: Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Visibility(
                                  visible: appSettings.playerCount > 1,
                                  child: _playerIndicator(
                                      context, appModel, appSettings, 2),
                                ),
                                Visibility(
                                  visible: appSettings.playerCount > 3,
                                  child: const SizedBox(height: _widgetMargin),
                                ),
                                // Margin
                                Visibility(
                                  visible: appSettings.playerCount > 3,
                                  child: _playerIndicator(
                                      context, appModel, appSettings, 4),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Visibility(
                          visible: appSettings.playerCount > 4,
                          child: const SizedBox(width: _widgetMargin),
                        ),
                        Visibility(
                          visible: appSettings.playerCount > 4,
                          child: _playerIndicator(
                              context, appModel, appSettings, 5),
                        ), // Margin
                      ]),
                )
              ],
            );
          }),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: pauseButtonDiameter + _widgetMargin * 2,
              height: pauseButtonDiameter + _widgetMargin * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
                onPressed: () => {
                      Provider.of<MyAppModel>(context, listen: false)
                          .togglePaused()
                    },
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(pauseButtonDiameter, pauseButtonDiameter),
                  shape: const CircleBorder(),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child:
                    Consumer<MyAppModel>(builder: (context, appModel, child) {
                  return Icon(
                    Provider.of<MyAppModel>(context, listen: false).isPaused
                        ? Icons.play_arrow_sharp
                        : Icons.pause_sharp,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    size: pauseButtonDiameter * 0.4,
                  );
                })),
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
      bottom: [3, 4].contains(thisPlayer) ? 0 : 4);
}

BoxDecoration playerButtonDecoration(context, thisPlayer, currentPlayer) {
  Color colorActive = Theme.of(context).cardColor;
  Color colorInactive = Theme.of(context).focusColor;

  return BoxDecoration(
    color: thisPlayer == currentPlayer ? colorActive : colorInactive,
  );
}

TextStyle playerTextStyle(BuildContext context, MyAppModel appModel,
    MyAppSettings appSettings, thisPlayer) {
  Color colorActive = Theme.of(context).colorScheme.primary;
  Color colorInactive = Theme.of(context).disabledColor;
  Color textColor =
      thisPlayer == appModel.currentPlayer ? colorActive : colorInactive;

  // TODO: appSettings.currentTimers[#] should be multiplied by 60
  if (appSettings.selectedTimer == 1) {
    if (appModel.playerTime(thisPlayer) > appSettings.playerTimeLimit) {
      textColor = Theme.of(context).colorScheme.error;
    }
  } else if (appSettings.selectedTimer == 2) {
    if (appModel.totalTime() >= appSettings.tournamentTimeLimit) {
      textColor = Theme.of(context).colorScheme.error;
    }
  }
  return TextStyle(
    fontSize: 50,
    color: textColor,
  );
}
