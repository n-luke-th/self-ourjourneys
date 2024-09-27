/// lib/main.dart
/// a starting point of the application

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:xiaokeai/firebase_options.dart';
import 'package:xiaokeai/helpers/dependencies_injection.dart';
import 'package:xiaokeai/helpers/get_platform_service.dart';
import 'package:xiaokeai/helpers/logger_provider.dart';
import 'package:xiaokeai/services/configs/appearance/lang/language_provider.dart';
import 'package:xiaokeai/services/configs/appearance/theme/theme_provider.dart';
import 'package:xiaokeai/services/configs/settings_service.dart';
import 'package:xiaokeai/services/notifications/notification_manager.dart';
import 'package:xiaokeai/services/package/package_info_provider.dart';
import 'package:xiaokeai/services/package/package_info_service.dart';
import 'package:xiaokeai/services/pref/shared_pref_service.dart';

late LanguageProvider languageProvider;
late ThemeProvider themeProvider;

Future<void> _configureServices() async {
  setupLogger();
  await _configureFirebaseService();
  await setupDependencies();
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
    languageProvider = LanguageProvider();
    themeProvider = ThemeProvider();
    await languageProvider.loadFromPrefs();
    await themeProvider.loadFromPrefs();
    FlutterNativeSplash.remove();
    LoadingAnimationWidget.fourRotatingDots(
      color: Color(0xFF8FE8FF),
      size: 35,
    );
    final settingsService = SettingsService(
        languageProvider: languageProvider, themeProvider: themeProvider);
    await logSettingsConfig();
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
  runZonedGuarded(() {
    _main();
  }, (error, stackTrace) {
    final Logger logger = locator<Logger>();
    logger.e(error.toString(), error: error, stackTrace: stackTrace);
  });
}

Future<void> logSettingsConfig() async {
  final Logger logger = locator<Logger>();
  SharedPreferencesService prefs = getIt<SharedPreferencesService>();
  final platformService = getIt<PlatformDetectionService>();
  final packageInfoService = getIt<PackageInfoService>();
  final packageInfo = await packageInfoService.getPackageInfo();
  logger.d("\tXiaokeai:\n"
      ">>> Platform: '${platformService.readableCurrentPlatform}'\n"
      ">>> Version '${packageInfo.version}'");
  logger.d("\tUser Preferences:\n"
      ">>> Language Code: '${prefs.getString('languageCode')}'\n"
      ">>> Is System Default Language: '${prefs.getBool('isSystemDefault')}'\n"
      ">>> Theme Mode: '${ThemeMode.values[prefs.getInt('themeMode') ?? ThemeMode.system.index].toString().split('.').last}'\n"
      //
      "\tApplied Settings:\n"
      ">>> Language: '${languageProvider.currentLocale.languageCode}'\n"
      ">>> Is System Default Language: '${languageProvider.isSystemDefault}'\n"
      ">>> Theme Mode: '${themeProvider.themeMode.toString().split(".").last}'");
}

class Xiaokeai extends StatelessWidget {
  const Xiaokeai({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(builder: (context, settings, child) {
      return GlobalLoaderOverlay(
        child: MaterialApp(
          title: 'Xiaokeai',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            FormBuilderLocalizations.delegate,
          ],
          supportedLocales: settings.supportedLocales,
          locale: settings.currentLocale,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          home: const MyHomePage(title: 'Xiaokeai'),
          builder: (context, child) {
            return child ?? const SizedBox.shrink();
          },
        ),
      );
    });
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
