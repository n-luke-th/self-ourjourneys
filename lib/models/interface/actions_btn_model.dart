/// lib/models/interface/actions_btn_model.dart
///

import 'package:flutter/widgets.dart' show Icon;

/// model for the action buttons to be used in the [MoreActionsBtn] widget
class ActionsBtnModel {
  final String actionName;
  final String? actionDes;
  final Icon icon;
  final void Function() onPressed;

  ActionsBtnModel(
      {required this.actionName,
      required this.icon,
      required this.onPressed,
      this.actionDes});
}
