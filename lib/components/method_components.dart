/// lib/components/method_components.dart
/// A class of methods components

// ignore_for_file: use_build_context_synchronously

import 'dart:async' show Future, FutureOr;

import 'package:flutter/material.dart';
import 'package:ourjourneys/services/bottom_sheet/bottom_sheet_service.dart'
    show BottomSheetService;
import 'package:ourjourneys/services/dialog/dialog_service.dart'
    show DialogService;
import 'package:ourjourneys/shared/views/ui_consts.dart' show UiConsts;
import 'package:shimmer/shimmer.dart' show Shimmer, ShimmerDirection;

/// A class of methods components
class MethodsComponents {
  /// a widget to display a bottom sheet line decoration
  ///
  /// mostly be on the top of the bottom sheet to indicate the adjustable size of the bottom sheet
  static Container buildBottomSheetLineDec(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
        borderRadius: UiConsts.BorderRadiusCircular_mediumLarge,
      ),
    );
  }

  /// a widget to show has action to take on settings page
  static Row buildSettingPageTakeOnActionBtn(
      {List<Widget> children = const []}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...children,
        UiConsts.spaceForTextAndElement,
        const Icon(Icons.arrow_forward_ios, size: UiConsts.smallIconSize),
      ],
    );
  }

  /// upload source selector component
  ///
  /// this component is used to select the source of the upload
  static Future<void> showUploadSourceSelector(BuildContext context,
      {required FutureOr<void> Function() onServerSourceSelected,
      required FutureOr<void> Function() onLocalSourceSelected}) async {
    await BottomSheetService.showCustomBottomSheet(
        context: context,
        initialChildSize: 0.3,
        builder: (context, scrollController) {
          return Column(
            children: [
              buildBottomSheetLineDec(context),
              const Text("Select File Source"),
              const Divider(),
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: UiConsts.BorderRadiusCircular_mediumLarge),
                title: const Text(
                  "Local Files",
                  textAlign: TextAlign.center,
                ),
                onTap: () async => await onLocalSourceSelected(),
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: UiConsts.BorderRadiusCircular_mediumLarge),
                title: const Text(
                  "Server Files",
                  textAlign: TextAlign.center,
                ),
                onTap: () async => await onServerSourceSelected(),
              ),
            ],
          );
        });
  }

  /// show pop page confirmation dialog
  ///
  /// useful when you want to confirm the user before leaving the page
  static Future<void> showPopPageConfirmationDialog(
      BuildContext context) async {
    await DialogService.showConfirmationDialog(
            context: context,
            title: "Leave the page?",
            message: "Are you sure to discard the progress and leave the page?",
            confirmText: "DISCARD & LEAVE",
            cancelText: "CANCEL")
        .then((value) async {
      if (value == true) {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  /// show shimmer effect
  ///
  /// useful when you want to show a shimmer loading effect for loading progress placeholder widget
  ///
  /// - [Shimmer] which [gradient] is [LinearGradient] made up of [baseColor] and [highlightColor] along with [shimmerBaseOpacity]
  /// - [effectDirection] optionally defines the direction of the [Shimmer] effect
  /// - [height] and [width] are optional
  static Shimmer renderShimmerEffect(
      {Color baseColor = Colors.blueGrey,
      Color highlightColor = Colors.white,
      double shimmerBaseOpacity = 0.5,
      double? height,
      double? width,
      ShimmerDirection effectDirection = ShimmerDirection.ltr}) {
    return Shimmer.fromColors(
      baseColor: baseColor.withValues(
          alpha: Color.getAlphaFromOpacity(shimmerBaseOpacity).toDouble()),
      highlightColor: highlightColor.withValues(
          alpha: Color.getAlphaFromOpacity(shimmerBaseOpacity).toDouble()),
      direction: effectDirection,
      child: Container(
        width: width,
        height: height,
        color: baseColor,
      ),
    );
  }
}
