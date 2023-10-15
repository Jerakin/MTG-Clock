import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '/models.dart';

const double _widgetMargin = 8;

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double pauseButtonDiameter =
        min(MediaQuery.of(context).size.height, screenWidth) * 0.25;

    return Center(
      child: Stack(
        children: [
          Consumer2<MyAppModel, MyAppSettings>(
              builder: (context, appModel, appSettings, child) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                timerBar(context, appModel, appSettings, Alignment.bottomLeft,
                    screenWidth),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Visibility(
                          visible: appSettings.playerCount > 5,
                          child: _playerIndicator(
                              context, appModel, appSettings, 6),
                        ),
                        Visibility(
                          visible: appSettings.playerCount > 5,
                          child: const SizedBox(height: _widgetMargin),
                        ),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Visibility(
                                visible: appSettings.playerCount > 2,
                                child: _playerIndicator(
                                    context, appModel, appSettings, 3),
                              ),
                              Visibility(
                                visible: appSettings.playerCount > 2,
                                child: const SizedBox(width: _widgetMargin),
                              ),
                              _playerIndicator(
                                  context, appModel, appSettings, 1),
                            ],
                          ),
                        ),
                        const SizedBox(height: _widgetMargin),
                        Visibility(
                          visible: appSettings.playerCount > 1,
                          child: Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Visibility(
                                  visible: appSettings.playerCount > 3,
                                  child: _playerIndicator(
                                      context, appModel, appSettings, 4),
                                ),
                                Visibility(
                                  visible: appSettings.playerCount > 3,
                                  child: const SizedBox(width: _widgetMargin),
                                ),
                                Visibility(
                                  visible: appSettings.playerCount > 1,
                                  child: _playerIndicator(
                                      context, appModel, appSettings, 2),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Visibility(
                          visible: appSettings.playerCount > 4,
                          child: const SizedBox(height: _widgetMargin),
                        ),
                        Visibility(
                          visible: appSettings.playerCount > 4,
                          child: _playerIndicator(
                              context, appModel, appSettings, 5),
                        ), // Margin
                      ]),
                ),
                timerBar(context, appModel, appSettings, Alignment.topRight,
                    screenWidth)
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
                  return playButtonContent(
                      context, appModel, pauseButtonDiameter);
                })),
          ),
        ],
      ),
    );
  }
}

Widget playButtonContent(
    BuildContext context, MyAppModel appModel, pauseButtonDiameter) {
  if (appModel.totalTime().inMilliseconds <= 0) {
    return Icon(
      Icons.play_arrow_sharp,
      color: Theme.of(context).scaffoldBackgroundColor,
      size: pauseButtonDiameter * 0.4,
    );
  } else if (appModel.isPaused) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AutoSizeText(appModel.getFormattedTime(appModel.totalTime(),),
            maxLines: 1,
            minFontSize: 15,
            style: const TextStyle(fontSize: 50)),
        AutoSizeText("Total",
            maxFontSize: 20,
            maxLines: 1,
            style:
                TextStyle(color: Theme.of(context).disabledColor, fontSize: 20))
      ],
    );
  }

  return Icon(
    Icons.pause_sharp,
    color: Theme.of(context).scaffoldBackgroundColor,
    size: pauseButtonDiameter * 0.4,
  );
}

Align timerBar(BuildContext context, MyAppModel appModel,
    MyAppSettings appSettings, Alignment alignment, screenWidth) {
  return Align(
      alignment: alignment,
      child: Visibility(
        visible: appSettings.selectedTimer != 3,
        child: SizedBox(
          width: _widgetMargin * 0.5,
          height:
              screenWidth * (appModel.totalTime().inSeconds / appSettings.getTotalTime().inSeconds),
          child: DecoratedBox(
              decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
          )),
        ),
      ));
  // Margin
}

Expanded _playerIndicator(BuildContext context, MyAppModel appModel,
    MyAppSettings appSettings, playerNum) {
  int quarterTurns = 0;
  if (playerNum == 1) {
    quarterTurns = 3;
    if (appSettings.playerCount < 3) {
      quarterTurns = 2;
    }
  } else if (playerNum == 2) {
    quarterTurns = 3;
    if (appSettings.playerCount < 4) {
      quarterTurns = 0;
    }
  } else if (playerNum == 3) {
    quarterTurns = 1;
  } else if (playerNum == 4) {
    quarterTurns = 1;
  } else if (playerNum == 4) {
    quarterTurns = 0;
  } else if (playerNum == 6) {
    quarterTurns = 2;
  }

  String timerText = "";
  if (appSettings.selectedTimer == 1){
    timerText = appModel.getFormattedTime(appSettings.playerTimeLimit - appModel.playerTime(playerNum), includeMilliseconds: true);
  } else {
    timerText = appModel.getPlayerTimeString(playerNum);
  }

  return Expanded(
    child: InkWell(
      child: Container(
        decoration:
            playerButtonDecoration(context, playerNum, appModel.currentPlayer),
        child: Center(
            child: RotatedBox(
          quarterTurns: quarterTurns,
          child: Text(
            timerText,
            style: playerTextStyle(context, appModel, appSettings, playerNum),
          ),
        )),
      ),
      onTap: () => appModel.passTurn(playerNum, appSettings.playerCount),
    ),
  );
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
    if (appSettings.playerTimeLimit - appModel.playerTime(thisPlayer) <= const Duration()) {
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
