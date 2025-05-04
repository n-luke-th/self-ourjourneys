/// lib/components/main_view.dart
///
/// main view wrapper

import 'package:flutter/material.dart';

Scaffold mainView(
  BuildContext context, {
  String? appBarTitle = 'changeMe',
  required Widget body,
  Widget? appBarLeading,
  double? leadingWidth,
  bool automaticallyImplyLeading = true,
  List<Widget>? appbarActions = const [],
  PreferredSizeWidget? appbarBottom,
  Color? appBarBackgroundColor,
  Color? backgroundColor,
  bool? extendBodyBehindAppBar = false,
  bool showFloatingActionButton = false,
  IconData? floatingActionButtonIcon = Icons.add,
  String? floatingActionButtonTooltip = "Create new",
  void Function()? onFloatingActionButtonPressed,
  FloatingActionButtonLocation floatingActionButtonLocation =
      FloatingActionButtonLocation.miniEndFloat,
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
    extendBodyBehindAppBar: extendBodyBehindAppBar!,
    appBar: AppBar(
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
    ),
    backgroundColor:
        backgroundColor ?? Theme.of(context).colorScheme.secondaryContainer,
    body: body,
    bottomSheet: bottomSheet,
    bottomNavigationBar: bottomNavigationBar,
    persistentFooterAlignment: AlignmentDirectional.bottomCenter,
    persistentFooterButtons: persistentFooterButtons,
    floatingActionButton: showFloatingActionButton == true
        ? FloatingActionButton(
            tooltip: floatingActionButtonTooltip,
            onPressed: () => onFloatingActionButtonPressed!(),
            child: Icon(floatingActionButtonIcon),
          )
        : null,
    floatingActionButtonLocation: floatingActionButtonLocation,
  );
}
