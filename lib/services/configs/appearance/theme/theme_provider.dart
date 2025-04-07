/// lib/services/configs/appearance/theme/theme_provider.dart
///
/// a theme provider that wraps the collection
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:ourjourneys/helpers/dependencies_injection.dart';
import 'package:ourjourneys/services/configs/appearance/theme/theme_collections.dart';
import 'package:ourjourneys/services/pref/shared_pref_service.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  final Logger _logger = getIt<Logger>();
  final SharedPreferencesService _prefs = getIt<SharedPreferencesService>();

  ThemeProvider() {
    loadFromPrefs();
  }

  ThemeMode get themeMode => _themeMode;
  ThemeData get lightTheme => ThemeCollections.LightTheme;
  ThemeData get darkTheme => ThemeCollections.DarkTheme;

  Future<bool> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _saveToPrefs();
    return true;
  }

  Future<void> loadFromPrefs() async {
    _themeMode =
        ThemeMode.values[_prefs.getInt('themeMode') ?? ThemeMode.system.index];

    // Apply user preference before falling back to system default
    if (_themeMode == ThemeMode.system) {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      _themeMode =
          brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    }
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    await _prefs.setInt('themeMode', _themeMode.index);
    _logger.i(
        "\t New Prefs: Theme mode: '${ThemeMode.values[_prefs.getInt('themeMode') ?? ThemeMode.system.index].toString().split('.').last}'");
  }
}
