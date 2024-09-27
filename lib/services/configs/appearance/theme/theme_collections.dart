/// lib/services/configs/appearance/theme_collections.dart
/// Theme collections
/// Config how the application theme will be here
// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:ui';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeCollections {
  ThemeCollections._();
  static final _defaultFont = GoogleFonts.itim().fontFamily;
  static final _fallbackFonts = <String>[
    GoogleFonts.longCang().fontFamily!,
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
    primary: Color(0xFFD1FF9D), //
    secondary: Color(0xFFFFF88F), //
    tertiary: Color(0xFFFFB1D6), //
    appBarColor: Color(0xFF8FE8FF), //
    error: Color(0xFFD11414), //
  );
  static const FlexSchemeColor _DarkThemeColors = FlexSchemeColor(
    primary: Color(0xFF1A9B1A), //
    secondary: Color(0xFF414100), //
    tertiary: Color(0xFF41002F), //
    appBarColor: Color(0xFF00212F), //
    error: Color(0xFFA30909), //
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
