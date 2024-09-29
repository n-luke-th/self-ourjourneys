/// lib/components/main_view.dart
///
/// main view wrapper

import 'package:flutter/material.dart';

Scaffold mainView(BuildContext context,
    {String? appBarTitle = 'changeMe',
    required Widget body,
    List<Widget>? appbarActions = const [],
    Color? appBarBackgroundColor,
    bool? extendBodyBehindAppBar = false}) {
  return Scaffold(
      appBar: AppBar(
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        backgroundColor: appBarBackgroundColor ??
            Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          appBarTitle!,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        actions: appbarActions,
      ),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      body: body);
}
