/// lib/models/interface/actions_btn_model.dart
///
/// model for the action buttons
import 'package:flutter/widgets.dart' show Icon;

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
