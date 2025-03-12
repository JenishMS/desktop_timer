import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  windowManager.setPreventClose(true);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener, TrayListener {
  DateTime startTime = DateTime.now();
  String screenTime = '00hrs 00mins 00sec';

  @override
  void initState() {
    super.initState();
    _initTray();
    windowManager.addListener(this);
    Timer.periodic(
      const Duration(seconds: 15),
      (timer) {
        setState(() {
          DateTime now = DateTime.now();
          final duration = now.difference(startTime);
          screenTime = _formatDuration(duration);
        });
      },
    );
  }

  _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final hours = (totalSeconds / 3600).floor().toString().padLeft(2, '0');
    final minutes =
        ((totalSeconds % 3600) / 60).floor().toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).floor().toString().padLeft(2, '0');
    return '${hours}hrs ${minutes}mins ${seconds}sec';
  }

  @override
  void onWindowClose() async {
    windowManager.hide();
  }

  @override
  void onTrayIconMouseDown() {
    _showWindow();
  }

  Future<void> _initTray() async {
    trayManager.addListener(this);
    await trayManager.setIcon('assets/icon.ico'); // Set tray icon
    await trayManager.setToolTip("Flutter Windows App"); // Tooltip
    await trayManager.setContextMenu(Menu(items: [
      MenuItem(label: "Show App", onClick: (menuItem) => _showWindow()),
      MenuItem(label: "Exit", onClick: (menuItem) => _exitApp()),
    ]));
  }

  void _showWindow() {
    windowManager.show(); // Restore window
    windowManager.focus();
  }

  void _exitApp() {
    trayManager.destroy();
    windowManager.destroy();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.teal,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'System Screen Timer',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.teal,
        ),
        body: Center(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Screen Time',
                  style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Text(
                  screenTime,
                  style: const TextStyle(
                      fontSize: 32.0, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
