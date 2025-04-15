/// lib/components/main_view.dart
///
/// main view wrapper

import 'package:flutter/material.dart';

Scaffold mainView(
  BuildContext context, {
  String? appBarTitle = 'changeMe',
  required Widget body,
  List<Widget>? appbarActions = const [],
  Color? appBarBackgroundColor,
  Color? backgroundColor,
  bool? extendBodyBehindAppBar = false,
  bool showFloatingActionButton = false,
  IconData? floatingActionButtonIcon = Icons.add,
  String? floatingActionButtonTooltip = "Create new",
  void Function()? onFloatingActionButtonPressed,
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
      actions: appbarActions,
    ),
    backgroundColor:
        backgroundColor ?? Theme.of(context).colorScheme.secondaryContainer,
    body: body,
    floatingActionButton: showFloatingActionButton == true
        ? FloatingActionButton(
            tooltip: floatingActionButtonTooltip,
            onPressed: () => onFloatingActionButtonPressed!(),
            child: Icon(floatingActionButtonIcon),
          )
        : null,
    floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
  );
}
