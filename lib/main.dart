/// lib/main.dart
/// a starting point of the application

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';
import 'package:ourjourneys/firebase_options.dart';
import 'package:ourjourneys/helpers/dependencies_injection.dart';
import 'package:ourjourneys/helpers/get_platform_service.dart';
import 'package:ourjourneys/navigation/page_router.dart';
import 'package:ourjourneys/services/auth/acc/auth_service.dart';
import 'package:ourjourneys/services/configs/appearance/theme/theme_provider.dart';
import 'package:ourjourneys/services/configs/settings_service.dart';
import 'package:ourjourneys/services/notifications/notification_manager.dart';
import 'package:ourjourneys/services/package/package_info_provider.dart';
import 'package:ourjourneys/services/package/package_info_service.dart';
import 'package:ourjourneys/services/pref/shared_pref_service.dart';
import 'package:provider/provider.dart';

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
    final ThemeProvider themeProvider = ThemeProvider();
    await themeProvider.loadFromPrefs();
    FlutterNativeSplash.remove();
    LoadingAnimationWidget.fourRotatingDots(
      color: Color(0xFF8FE8FF),
      size: 35,
    );
    final settingsService = SettingsService(themeProvider: themeProvider);
    await logSettingsConfig(themeProvider: themeProvider);
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            // meta data of the app from `pubspec.yaml`
            create: (_) => getIt<PackageInfoProvider>(),
          ),
          // setting page service
          ChangeNotifierProvider.value(value: settingsService),
          // auth notifier helper
          ChangeNotifierProvider(create: (_) => getIt<AuthService>()),
          // notification service
          ProxyProvider<SettingsService, NotificationManager>(
            update: (_, settings, __) => NotificationManager(settings),
            dispose: (_, manager) => manager.dispose(),
          ),
        ],
        child: OurJourneys(),
      ),
    );
  } on Exception catch (e) {
    final Logger logger = getIt<Logger>();
    logger.e(e.toString(), error: e, stackTrace: StackTrace.current);
    runApp(Text("Error starting the app: ${e.toString()}"));
  }
}

void main() {
  runZonedGuarded(() {
    _main();
  }, (error, stackTrace) {
    final Logger logger = getIt<Logger>();
    logger.e(error.toString(), error: error, stackTrace: stackTrace);
  });
}

Future<void> logSettingsConfig({required ThemeProvider themeProvider}) async {
  final Logger logger = getIt<Logger>();
  SharedPreferencesService prefs = getIt<SharedPreferencesService>();
  final platformService = getIt<PlatformDetectionService>();
  final packageInfoService = getIt<PackageInfoService>();
  final packageInfo = await packageInfoService.getPackageInfo();
  logger
      .d("${DateTime.now().toLocal()}: Application is starting/restarting...");
  logger.d("\tOurJourneys:\n"
      ">>> Platform: '${platformService.readableCurrentPlatform}'\n"
      ">>> Version '${packageInfo.version}'\n"
      ">>> Package Name: '${packageInfo.packageName}'\n"
      //
      "\tUser Preferences:\n"
      ">>> Language Code: '${prefs.getString('languageCode')}'\n"
      ">>> Is System Default Language: '${prefs.getBool('isSystemDefault')}'\n"
      ">>> Theme Mode: '${ThemeMode.values[prefs.getInt('themeMode') ?? ThemeMode.system.index].toString().split('.').last}'\n"
      //
      "\tApplied Settings:\n"
      ">>> Theme Mode: '${themeProvider.themeMode.toString().split(".").last}'");
}

class OurJourneys extends StatelessWidget {
  const OurJourneys({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(builder: (context, settings, child) {
      return GlobalLoaderOverlay(
        overlayColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        overlayWidgetBuilder: (progress) => Center(
          child: LoadingAnimationWidget.beat(
            // color: Color(0xFF8FE8FF),
            color: Theme.of(context).colorScheme.primary,
            size: 56,
          ),
        ),
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'OurJourneys',
          supportedLocales: const <Locale>[Locale('en', 'US')],
          locale: Locale("en", "US"),
          themeMode: settings.themeMode,
          theme: settings.themeProvider.lightTheme,
          darkTheme: settings.themeProvider.darkTheme,
          routerConfig: router,
          builder: (context, child) {
            return child ?? const SizedBox.shrink();
          },
        ),
      );
    });
  }
}
