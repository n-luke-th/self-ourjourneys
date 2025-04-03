/// lib/services/configs/appearance/lang/language_provider.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import 'package:xiaokeai/helpers/dependencies_injection.dart';
import 'package:xiaokeai/helpers/logger_provider.dart';
import 'package:xiaokeai/l10n/generated/i18n/app_localizations.dart'
    show AppLocalizations;
import 'package:xiaokeai/services/pref/shared_pref_service.dart';

class LanguageProvider with ChangeNotifier {
  final Logger _logger = locator<Logger>();
  static const Locale defaultAppLocale = Locale('en');
  late Locale _currentLocale;
  final SharedPreferencesService _prefs = getIt<SharedPreferencesService>();
  bool _isSystemDefault = true;

  LanguageProvider() {
    _currentLocale = defaultAppLocale; // Default fallback
    loadFromPrefs();
  }

  Locale get currentLocale => _currentLocale;
  bool get isSystemDefault => _isSystemDefault;

  List<Locale> get supportedLocales => AppLocalizations.supportedLocales;

  // List<Locale> get availableLocales => AppLocalizations.supportedLocales
  //     .sublist(0)
  //   ..remove(Locale(Intl.shortLocale(LanguageProvider.systemDefaultLocale)));
  Locale? get currentLocaleOrNull => _isSystemDefault ? null : _currentLocale;

  List<Locale?> get supportedLocalesWithDefault => [null, ...supportedLocales];

  static final String systemDefaultLocale =
      WidgetsBinding.instance.platformDispatcher.locales.first.toString();

  String getLanguageNameByLocaleString({required String aLocale}) {
    final localeString = Intl.shortLocale(aLocale); // simplify into XX format
    final localeInstance = Locale(localeString);
    switch (localeInstance.languageCode) {
      case 'en':
        return 'English'; // English
      case 'th':
        return 'ไทย'; // Thai
      // case 'zh':
      //   return '中文'; // Chinese
      default:
        return Intl.canonicalizedLocale(localeInstance.languageCode);
    }
  }

  String getLanguageName(Locale? locale, BuildContext context) {
    if (locale == null) {
      String defaultText = AppLocalizations.of(context)!.systemDefault;
      String defaultLangText =
          getLanguageNameByLocaleString(aLocale: systemDefaultLocale);
      return "$defaultText ($defaultLangText)";
    }
    return getLanguageNameByLocaleString(aLocale: locale.toString());
  }

  Future<bool> setLocale(Locale? locale) async {
    if ((locale == null) ||
        (locale.languageCode == Intl.shortLocale(systemDefaultLocale))) {
      _isSystemDefault = true;
      setSystemLocale();
      return true;
    } else if (supportedLocales.contains(locale)) {
      _currentLocale = locale;
      _isSystemDefault = false;
      notifyListeners();
      await _saveToPrefs();
      return true;
    }
    return false;
  }

  Future<void> loadFromPrefs() async {
    final String? languageCode = _prefs.getString('languageCode');
    final bool? isSystemDefault = _prefs.getBool('isSystemDefault');

    if (isSystemDefault == false && languageCode != null) {
      _currentLocale = Locale(languageCode);
      _isSystemDefault = false;
    } else {
      await setSystemLocale();
    }
    notifyListeners();
  }

  Future<void> setSystemLocale() async {
    final List<Locale> systemLocales =
        WidgetsBinding.instance.platformDispatcher.locales;
    final Locale matchedLocale = systemLocales.firstWhere(
      (Locale locale) => supportedLocales.contains(Locale(locale.languageCode)),
      orElse: () =>
          defaultAppLocale, // Default to default app determined locale if not supported
    );
    _currentLocale = matchedLocale;
    _isSystemDefault = true;
    notifyListeners();
    _saveToPrefs();
  }

  Future<void> _saveToPrefs() async {
    await _prefs.setString('languageCode', _currentLocale.languageCode);
    await _prefs.setBool('isSystemDefault', _isSystemDefault);
    final String? languageCode = _prefs.getString('languageCode');
    final bool? isSystemDefault = _prefs.getBool('isSystemDefault');
    _logger.d(
        "\t New Prefs: Language code: '$languageCode' | Is system default lang: '$isSystemDefault'");
  }
}
