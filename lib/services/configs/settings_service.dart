/// lib/services/configs/settings_service.dart
///
///
/// services for settings of the app
///

import 'package:flutter/material.dart';
import 'package:xiaokeai/helpers/dependencies_injection.dart';
import 'package:xiaokeai/services/configs/appearance/lang/language_provider.dart';
import 'package:xiaokeai/services/configs/appearance/theme/theme_provider.dart';
import 'package:xiaokeai/services/pref/shared_pref_service.dart';

class SettingsService with ChangeNotifier {
  final LanguageProvider languageProvider;
  final ThemeProvider themeProvider;
  final SharedPreferencesService _prefs = getIt<SharedPreferencesService>();
  SettingsService(
      {required this.languageProvider, required this.themeProvider}) {
    _init();
  }

  Future<void> _init() async {
    languageProvider.addListener(notifyListeners);
    themeProvider.addListener(notifyListeners);
  }

  // Language-related methods
  Locale get currentLocale => languageProvider.currentLocale;
  bool get isSystemDefault => languageProvider.isSystemDefault;
  List<Locale> get supportedLocales => languageProvider.supportedLocales;
  Locale? get currentLocaleOrNull => languageProvider.currentLocaleOrNull;
  List<Locale?> get supportedLocalesWithDefault =>
      languageProvider.supportedLocalesWithDefault;

  Future<bool> setLocale(Locale? locale) async {
    bool result = await languageProvider.setLocale(locale);
    notifyListeners();
    return result;
  }

  String getLanguageName(Locale? locale, BuildContext context) =>
      languageProvider.getLanguageName(locale, context);

  // Theme-related methods
  ThemeMode get themeMode => themeProvider.themeMode;
  ThemeData get lightTheme => themeProvider.lightTheme;
  ThemeData get darkTheme => themeProvider.darkTheme;

  Future<bool> setThemeMode(ThemeMode mode) async {
    bool result = await themeProvider.setThemeMode(mode);
    notifyListeners();
    return result;
  }

  @override
  void dispose() {
    super.dispose();
    languageProvider.removeListener(notifyListeners);
  }
}
