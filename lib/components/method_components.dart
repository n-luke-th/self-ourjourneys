/// lib/components/method_components.dart
/// A class of methods components

import 'dart:async' show Future, FutureOr;

import 'package:flutter/material.dart';
import 'package:ourjourneys/services/bottom_sheet/bottom_sheet_service.dart'
    show BottomSheetService;
import 'package:ourjourneys/shared/views/ui_consts.dart' show UiConsts;

/// A class of methods components
class MethodsComponents {
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
              const Text("Select File Source"),
              const Divider(),
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: UiConsts.BorderRadiusCircular_standard),
                title: const Text(
                  "Local Files",
                  textAlign: TextAlign.center,
                ),
                onTap: () async => await onLocalSourceSelected(),
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: UiConsts.BorderRadiusCircular_standard),
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
}
