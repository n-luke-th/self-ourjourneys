/// lib/components/main_view.dart
///
/// main view wrapper

import 'package:flutter/material.dart';

/// Returns a [Scaffold] with a [body] and an [AppBar] with a [title]
/// that can be customized to fit the needs of each page of the app.
///
/// serves as a standard wrapper for all pages of the app.
///
/// see [Scaffold] for more information.
Scaffold mainView(
  BuildContext context, {
  String? appBarTitle = 'changeMe',
  required Widget body,
  bool showAppBar = true,
  Widget? appBarLeading,
  double? leadingWidth,
  bool automaticallyImplyLeading = true,
  List<Widget>? appbarActions = const [],
  PreferredSizeWidget? appbarBottom,
  Color? appBarBackgroundColor,
  Color? backgroundColor,
  Color? appBarShadowColor,
  Widget? appBarFlexibleSpace,
  EdgeInsetsGeometry? appBarActionsPadding,
  bool? appBarTitleCentered,
  bool extendBody = false,
  bool extendBodyBehindAppBar = false,
  bool showFloatingActionButton = false,
  IconData? floatingActionButtonIcon = Icons.add,
  String? floatingActionButtonTooltip = "Create new",
  void Function()? onFloatingActionButtonPressed,
  FloatingActionButtonLocation floatingActionButtonLocation =
      FloatingActionButtonLocation.miniEndFloat,
  FloatingActionButton? floatingActionButtonProps,
  Widget? bottomSheet,
  Widget? bottomNavigationBar,
  AlignmentDirectional persistentFooterAlignment =
      AlignmentDirectional.bottomCenter,
  List<Widget>? persistentFooterButtons,
}) {
  if (showFloatingActionButton) {
    assert(onFloatingActionButtonPressed != null);
  }
  return Scaffold(
    extendBodyBehindAppBar: extendBodyBehindAppBar,
    extendBody: extendBody,
    appBar: showAppBar
        ? AppBar(
            foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
            backgroundColor: appBarBackgroundColor ??
                Theme.of(context).appBarTheme.backgroundColor,
            title: Text(
              appBarTitle!,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            automaticallyImplyLeading: automaticallyImplyLeading,
            leading: appBarLeading,
            leadingWidth: leadingWidth,
            actions: appbarActions,
            bottom: appbarBottom,
            centerTitle: appBarTitleCentered,
            flexibleSpace: appBarFlexibleSpace,
            actionsPadding: appBarActionsPadding,
            shadowColor: appBarShadowColor,
          )
        : null,
    backgroundColor:
        backgroundColor ?? Theme.of(context).colorScheme.secondaryContainer,
    body: body,
    bottomSheet: bottomSheet,
    bottomNavigationBar: bottomNavigationBar,
    persistentFooterAlignment: AlignmentDirectional.bottomCenter,
    persistentFooterButtons: persistentFooterButtons,
    floatingActionButton: showFloatingActionButton == true
        ? FloatingActionButton(
            key: floatingActionButtonProps?.key,
            foregroundColor: floatingActionButtonProps?.foregroundColor,
            backgroundColor: floatingActionButtonProps?.backgroundColor,
            focusColor: floatingActionButtonProps?.focusColor,
            hoverColor: floatingActionButtonProps?.hoverColor,
            splashColor: floatingActionButtonProps?.splashColor,
            heroTag: floatingActionButtonProps?.heroTag,
            elevation: floatingActionButtonProps?.elevation,
            focusElevation: floatingActionButtonProps?.focusElevation,
            hoverElevation: floatingActionButtonProps?.hoverElevation,
            highlightElevation: floatingActionButtonProps?.highlightElevation,
            disabledElevation: floatingActionButtonProps?.disabledElevation,
            mouseCursor: floatingActionButtonProps?.mouseCursor,
            mini: floatingActionButtonProps?.mini ?? false,
            shape: floatingActionButtonProps?.shape,
            clipBehavior: floatingActionButtonProps?.clipBehavior ?? Clip.none,
            focusNode: floatingActionButtonProps?.focusNode,
            autofocus: floatingActionButtonProps?.autofocus ?? false,
            materialTapTargetSize:
                floatingActionButtonProps?.materialTapTargetSize,
            isExtended: floatingActionButtonProps?.isExtended ?? false,
            enableFeedback: true,
            tooltip: floatingActionButtonTooltip,
            onPressed: () => onFloatingActionButtonPressed!(),
            child: Icon(floatingActionButtonIcon),
          )
        : null,
    floatingActionButtonLocation: floatingActionButtonLocation,
  );
}
