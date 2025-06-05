/// lib/services/configs/settings_service.dart
///
///
///

import 'package:flutter/material.dart'
    show ChangeNotifier, ThemeData, ThemeMode;
import 'package:ourjourneys/services/configs/appearance/theme/theme_provider.dart';

/// service class for settings of the app
class SettingsService with ChangeNotifier {
  final ThemeProvider themeProvider;
  SettingsService({required this.themeProvider}) {
    _init();
  }

  void _init() {
    themeProvider.addListener(notifyListeners);
  }

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
    themeProvider.removeListener(notifyListeners);
  }
}
