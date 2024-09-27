/// lib/main.dart
/// a starting point of the application

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:xiaokeai/firebase_options.dart';
import 'package:xiaokeai/helpers/dependencies_injection.dart';
import 'package:xiaokeai/helpers/logger_provider.dart';
import 'package:xiaokeai/services/configs/appearance/lang/language_provider.dart';
import 'package:xiaokeai/services/configs/settings_service.dart';
import 'package:xiaokeai/services/notifications/notification_manager.dart';
import 'package:xiaokeai/services/package/package_info_provider.dart';
import 'package:xiaokeai/services/pref/shared_pref_service.dart';

Future<void> _configureServices() async {
  setupLogger();
  await _configureFirebaseService();
  final Logger logger = locator<Logger>();
  await setupDependencies();
  SharedPreferencesService prefs = getIt<SharedPreferencesService>();
  logger.d(prefs.toString()); // TODO: log debug all key-value pairs
}

Future<FirebaseApp> _configureFirebaseService() async {
  return await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
}

void _main() async {
  try {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    await _configureServices();
    final languageProvider = LanguageProvider();
    await languageProvider.loadFromPrefs();
    FlutterNativeSplash.remove();
    LoadingAnimationWidget.fourRotatingDots(
      color: Colors.blueGrey,
      size: 30,
    );
    final settingsService = SettingsService(languageProvider: languageProvider);
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            // meta data of the app from `pubspec.yaml`
            create: (_) => getIt<PackageInfoProvider>(),
          ),
          // setting page service
          ChangeNotifierProvider.value(value: settingsService),
          // notification service
          ProxyProvider<SettingsService, NotificationManager>(
            update: (_, settings, __) => NotificationManager(settings),
            dispose: (_, manager) => manager.dispose(),
          ),
        ],
        child: const Xiaokeai(),
      ),
    );
  } on Exception catch (e) {
    runApp(Text("Error starting the app: ${e.toString()}"));
  }
}

void main() {
  final Logger logger = locator<Logger>();
  runZonedGuarded(() {
    _main();
  }, (error, stackTrace) {
    logger.e(error.toString(), error: error, stackTrace: stackTrace);
  });
}

class Xiaokeai extends StatelessWidget {
  const Xiaokeai({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xiaokeai',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Xiaokeai'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
