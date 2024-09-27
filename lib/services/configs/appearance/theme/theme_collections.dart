/// lib/services/configs/appearance/theme_collections.dart
/// Theme collections
/// Config how the application theme will be here
// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:ui';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeCollections {
  // TODO: finalize the app theme settings
  ThemeCollections._();
  static final _defaultFont = GoogleFonts.roboto().fontFamily;
  static final _fallbackFonts = <String>[
    GoogleFonts.sarabun().fontFamily!,
    GoogleFonts.montserrat().fontFamily!,
  ];
  static final _visualDensity = FlexColorScheme.comfortablePlatformDensity;
  static const _subThemesData = FlexSubThemesData(
    blendOnLevel: 10,
    blendOnColors: false,
    useTextTheme: true,
    useM2StyleDividerInM3: true,
    alignedDropdown: true,
    useInputDecoratorThemeInDialogs: true,
  );
  static const _blendLevel = 8;
  static const _surfaceMode = FlexSurfaceMode.levelSurfacesLowScaffold;
  static const FlexSchemeColor _LightThemeColors = FlexSchemeColor(
    primary: Color(0xffF2BE22),
    primaryContainer: Color(0xffFFFCAF), //
    secondary: Color(0xffFF6600), //
    secondaryContainer: Color.fromARGB(255, 199, 223, 201), //
    tertiary: Color(0xfffbbc66),
    tertiaryContainer: Color.fromARGB(255, 227, 164, 141), //
    // appBarColor: Color(0xff8ec5bf),
    error: Color(0xFFB1384E),
  );
  static const FlexSchemeColor _DarkThemeColors = FlexSchemeColor(
    primary: Color(0xfff87c50),
    primaryContainer: Color.fromARGB(255, 54, 49, 47), //
    secondary: Color(0xffFF6600),
    secondaryContainer: Color(0xff3a5444), //
    tertiary: Color(0xfffbbc66),
    tertiaryContainer: Color(0xff34553e), //
    // appBarColor: Color(0xff8ec5bf),
    error: Color(0xFFB1384E),
  );

  static final LightTheme = FlexThemeData.light(
    colors: _LightThemeColors,
    surfaceMode: _surfaceMode,
    blendLevel: _blendLevel,
    subThemesData: _subThemesData,
    visualDensity: _visualDensity,
    useMaterial3: true,
    swapLegacyOnMaterial3: true,
    fontFamily: _defaultFont,
    fontFamilyFallback: _fallbackFonts,
  );

  static final DarkTheme = FlexThemeData.dark(
    colors: _DarkThemeColors,
    surfaceMode: _surfaceMode,
    blendLevel: _blendLevel,
    subThemesData: _subThemesData,
    visualDensity: _visualDensity,
    useMaterial3: true,
    swapLegacyOnMaterial3: true,
    fontFamily: _defaultFont,
    fontFamilyFallback: _fallbackFonts,
  );
}
