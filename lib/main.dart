import 'package:flutter/material.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window manager
  await windowManager.ensureInitialized();
  windowManager.setPreventClose(true); // Prevent closing window

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener, TrayListener {
  @override
  void initState() {
    super.initState();
    _initTray();
    windowManager.addListener(this);
  }

  @override
  void onWindowClose() async {
    windowManager.hide(); // Hide to system tray instead of closing
  }

  @override
  void onTrayIconMouseDown() {
    _showWindow(); // Restore window when clicking the tray icon
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
      home: Scaffold(
        appBar: AppBar(title: Text("Flutter Windows System Tray")),
        body: Center(child: Text("Minimize to Tray Example")),
      ),
    );
  }
}
