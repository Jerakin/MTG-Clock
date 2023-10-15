import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '/models.dart';
import '/simple_prefs.dart';
import '/settings.dart';
import '/timer_screen.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await SimplePrefs.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EDH Timer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0x283d95)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            brightness: Brightness.dark, seedColor: const Color(0x283d95)),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: MultiProvider(providers: [
        ChangeNotifierProvider(create: (context) => MyAppModel()),
        ChangeNotifierProvider(create: (context) => MyAppSettings())
      ], child: const HomeScreen(title: 'EDH Timer')),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
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
            Consumer<MyAppModel>(builder: (context, appModel, child) {
          return Visibility(
              visible: appModel.isPaused,
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    currentScreenIndex = 1 - currentScreenIndex;
                  });
                },
                backgroundColor: Theme.of(context).cardColor,
                child: currentScreenIndex == 0
                    ? const Icon(Icons.settings)
                    : const Icon(Icons.arrow_forward_rounded),
              ));
        }));
  }
}
