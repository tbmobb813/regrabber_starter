import 'package:Regrabber/services/grab_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Regrabber/screens/home/home_screen.dart';
import 'package:Regrabber/screens/home/home_view_model.dart';
import 'package:Regrabber/services/download_service.dart';
import 'package:Regrabber/services/history_service.dart';
import 'package:Regrabber/services/clipboard_service.dart';
import 'package:Regrabber/services/settings_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(
            settingsService: SettingsService(),
            historyService: HistoryService(),
            grabService: GrabService(),
            downloadService: DownloadService(),
            clipboardService: ClipboardService(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReGrabber',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}
