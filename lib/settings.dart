import 'dart:collection';
import 'dart:html';
import 'dart:js_util';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:numberpicker/numberpicker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


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

  void onValueChanged(v) {
    setState(() {
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
    });
  }

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
                          onValueChanged(0);
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
                          onValueChanged(1);
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
                            onValueChanged(2);
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

bool isFalse(bool value) => (value == false);



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