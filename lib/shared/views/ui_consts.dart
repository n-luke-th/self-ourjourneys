/// lib/shared/views/ui_consts.dart
/// for consistent design and user interface of the app
/// we will define the spacing or things that might be reusable here
/// e.g. padding style, padding amount, font size, etc.
///
// ignore_for_file: constant_identifier_names, non_constant_identifier_names
/// TODO: edit this page
import 'package:flutter/widgets.dart';

class UiConsts {
  UiConsts._();

  /// EdgeInsets.all(8);
  static const PaddingAll_standard = EdgeInsets.all(8);

  /// EdgeInsets.all(16);
  static const PaddingAll_large = EdgeInsets.all(16);

  /// EdgeInsets.symmetric(horizontal: 8);
  static const PaddingHorizontal_standard = EdgeInsets.symmetric(horizontal: 8);

  /// EdgeInsets.symmetric(vertical: 8);
  static const PaddingVertical_standard = EdgeInsets.symmetric(vertical: 8);

  /// EdgeInsets.symmetric(vertical: 4);
  static const PaddingVertical_small = EdgeInsets.symmetric(vertical: 4);

  /// EdgeInsets.symmetric(horizontal: 4);
  static const PaddingHorizontal_small = EdgeInsets.symmetric(horizontal: 4);

  /// EdgeInsets.symmetric(vertical: 16.0)
  static const PaddingVertical_large = EdgeInsets.symmetric(vertical: 16.0);

  /// EdgeInsets.symmetric(horizontal: 16.0)
  static const PaddingHorizontal_large = EdgeInsets.symmetric(horizontal: 16.0);

  /// EdgeInsets.only(bottom: 16);
  static const PaddingBottom_large = EdgeInsets.only(bottom: 16);

  /// EdgeInsets.only(bottom: 24);
  static const PaddingBottom_extraLarge = EdgeInsets.only(bottom: 24);

  /// SizedBox(height: 8);
  static const SizedBoxGapVertical_standard = SizedBox(
    height: 8,
  );

  /// SizedBox(height: 16);
  static const SizedBoxGapVertical_large = SizedBox(
    height: 16,
  );

  /// SizedBox(width: 16);
  static const SizedBoxGapHorizontal_large = SizedBox(
    width: 16,
  );

  /// SizedBox(width: 8);
  static const SizedBoxGapHorizontal_standard = SizedBox(
    width: 8,
  );

  /// SizedBox(height: 4);
  static const SizedBoxGapVertical_small = SizedBox(
    height: 4,
  );

  /// SizedBox(width: 4);
  static const SizedBoxGapHorizontal_small = SizedBox(
    width: 4,
  );

  /// BorderRadius.circular(20)
  static var BorderRadiusCircular_standard = BorderRadius.circular(20);

  /// borderRadius = 20.0
  static const double borderRadius = 20.0;

  /// borderRadius = 45.0
  static const double borderRadius_large = 45.0;

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

  /// double 10
  static const double margin_standard = 10;

  ///  EdgeInsets.symmetric(horizontal: 50, vertical: 15)
  static const PaddingElevBtn =
      EdgeInsets.symmetric(horizontal: 50, vertical: 15);
}
