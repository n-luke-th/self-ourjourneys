/// lib/shared/views/ui_consts.dart
/// for consistent design and user interface of the app
/// we will define the spacing or things that might be reusable here
/// e.g. padding style, padding amount, font size, etc.
///
// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter/widgets.dart';

class UiConsts {
  /// EdgeInsets.all(8);
  static const PaddingAll_standard = EdgeInsets.all(8);

  /// EdgeInsets.all(16);
  static const PaddingAll_large = EdgeInsets.all(16);

  /// EdgeInsets.symmetric(horizontal: 8);
  static const PaddingHorizontal_standard = EdgeInsets.symmetric(horizontal: 8);

  /// EdgeInsets.symmetric(vertical: 8);
  static const PaddingVertical_standard = EdgeInsets.symmetric(vertical: 8);

  /// EdgeInsets.symmetric(vertical: 16.0)
  static const PaddingVertical_largeSmall2 =
      EdgeInsets.symmetric(vertical: 16.0);

  /// SizedBox(height: 10);
  static const SizedBoxGapVertical_standard = SizedBox(
    height: 10,
  );

  /// SizedBox(height: 20);
  static const SizedBoxGapVertical_large = SizedBox(
    height: 20,
  );

  /// SizedBox(width: 20);
  static const SizedBoxGapHorizontal_large = SizedBox(
    width: 20,
  );

  /// SizedBox(width: 10);
  static const SizedBoxGapHorizontal_standard = SizedBox(
    width: 10,
  );

  /// BorderRadius.circular(20)
  static var BorderRadiusCircular_standard = BorderRadius.circular(20);

  /// borderRadius = 20.0
  static const double borderRadius = 20.0;

  /// double 16
  static const double smallIconSize = 16;

  /// double 24
  static const double standardIconSize = 24;

  /// double 35
  static const double largeIconSize = 35;

  /// SizedBox(height: 5,width: 5)
  static const spaceForTextAndElement = SizedBox(
    height: 5,
    width: 5,
  );
}
