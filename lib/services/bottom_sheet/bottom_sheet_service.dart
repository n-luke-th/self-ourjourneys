/// lib/services/bottom_sheet/bottom_sheet_service.dart
///
/// a service file for bottom sheet
import 'package:flutter/material.dart';
import 'package:ourjourneys/shared/views/ui_consts.dart';

class BottomSheetService {
  static Future<T?> showCustomBottomSheet<T>({
    required BuildContext context,
    required Widget Function(BuildContext, ScrollController) builder,
    double initialChildSize = 0.55,
    double minChildSize = 0.2,
    double maxChildSize = 0.75,
    bool scrollable = true,
    Color? backgroundColor,
    double borderRadius = UiConsts.borderRadius,
    bool isDraggable = true,
    bool isDismissible = true,
    Duration snapAnimationDuration = const Duration(milliseconds: 300),
    double minWidth = 350.0, //  property for minimum width
    bool expandToContentWidth = false, //  property for flexible width expansion
  }) async {
    assert(initialChildSize <= 1);

    backgroundColor ??
        Theme.of(context)
            .colorScheme
            .primaryContainer; // override the color if none provide when calling (provided `null`)
    return await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: scrollable,
      enableDrag: isDraggable,
      isDismissible: isDismissible,
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        expand: false,
        snap: true,
        snapAnimationDuration: snapAnimationDuration,
        builder: (BuildContext context, ScrollController scrollController) {
          return SizedBox(
            width: minWidth > 0
                ? minWidth
                : null, // Set minimum width if specified
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.passthrough,
              children: [
                // Align(
                //   alignment: Alignment.topRight,
                //   child: Padding(
                //     padding: UiConsts.PaddingAll_standard,
                //     child: IconButton.filled(
                //         onPressed: () {
                //           Navigator.pop(context, true);
                //         },
                //         icon: const Icon(Icons.close_rounded)),
                //   ),
                // ),
                SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: UiConsts.PaddingAll_large,
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return SizedBox(
                          width: expandToContentWidth
                              ? constraints.maxWidth
                              : null, // Expand to content width if specified
                          child: builder(context, scrollController),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Future<T?> showOverrideBuilderBottomSheet<T>(
      {required BuildContext context, required Widget child}) async {
    return await showModalBottomSheet(
        context: context, builder: (context) => child);
  }
}
