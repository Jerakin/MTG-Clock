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

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const List<int> _list = <int>[2, 3, 4, 5, 6];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Consumer<MyAppSettings>(
        builder: (context, appSettings, child) {
          return ListView(
            children: [
              _SingleSection(
                title: "General",
                children: [
                  _CustomListTile(
                      title: "Players",
                      icon: Icons.people,
                      trailing: DropdownButton<int>(
                        value: appSettings.players,
                        onChanged: (int? value) {
                          // This is called when the user selects an item.
                          setState(() {
                            appSettings.players = value!;
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
                      subtitleWidget: Visibility(
                          visible: appSettings.isSelected[0],
                          child: const Text("Each player has this much time at which point their indicator will be lit up.",
                              style: TextStyle(fontStyle: FontStyle.italic)
                          )
                      ),
                      trailing: Switch(
                          value: appSettings.isSelected[0],
                          onChanged: (value) {
                            setState(() {
                              appSettings.setSelectedTimerStyle(0);
                            });
                          })
                  ),
                  Visibility(
                      visible: appSettings.isSelected[0],
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
                          PointerDeviceKind.touch,
                          PointerDeviceKind.mouse,
                        }),
                        child: NumberPicker(
                          selectedTextStyle: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0),
                          textStyle: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.0),
                          value: appSettings.currentTimers[0],
                          axis: Axis.horizontal,
                          itemCount: 5,
                          minValue: 10,
                          maxValue: 240,
                          step: 5,
                          onChanged: (value) {
                            setState(() {
                              appSettings.currentTimers[0] = value;
                            });
                          },
                        ),
                      )
                  ),
                  _CustomListTile(
                      title: "Total Time",
                      icon: Icons.watch_later_outlined,
                      subtitleWidget: Visibility(
                          visible: appSettings.isSelected[1],
                          child: const Text("Tournament style. Game will automatically pause when the time is over.",
                              style: TextStyle(fontStyle: FontStyle.italic)
                          )
                      ),
                      trailing: Switch(
                          value: appSettings.isSelected[1],
                          onChanged: (value) {
                            setState(() {
                              appSettings.setSelectedTimerStyle(1);
                            });
                          })
                  ),
                  Visibility(
                      visible: appSettings.isSelected[1],
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
                          PointerDeviceKind.touch,
                          PointerDeviceKind.mouse,
                        }),
                        child: NumberPicker(
                          selectedTextStyle: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0),
                          textStyle: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.0),
                          value: appSettings.currentTimers[1],
                          axis: Axis.horizontal,
                          itemCount: 5,
                          minValue: 10,
                          maxValue: 240,
                          step: 5,
                          onChanged: (value) {
                            setState(() {
                              appSettings.currentTimers[1] = value;
                            });
                          },
                        ),
                      )
                  ),
                  _CustomListTile(
                      title: "Stopwatch",
                      icon: Icons.timer_sharp,
                      subtitleWidget: Visibility(
                        visible: appSettings.isSelected[2],
                        child: const Text("No limit. Time keeps ticking up for everyone.",
                            style: TextStyle(fontStyle: FontStyle.italic)
                        )
                      ),
                      trailing: Switch(
                          value: appSettings.isSelected[2],
                          onChanged: (value) {
                            setState(() {
                              appSettings.setSelectedTimerStyle(2);
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
          );
        }
      ),
    );
  }
}




class _CustomListTile extends StatelessWidget {
  final String title;
  final Widget? subtitleWidget;
  final IconData icon;
  final Widget? trailing;
  const _CustomListTile(
      {Key? key, required this.title, required this.icon, this.trailing, this.subtitleWidget})
      : super(key: key);

    @override
  Widget build(BuildContext context) {
    return ListTile(
      subtitle: subtitleWidget,
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