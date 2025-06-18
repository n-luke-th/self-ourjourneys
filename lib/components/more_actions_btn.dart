/// lib/components/more_actions_btn.dart

import 'package:flutter/material.dart';
import 'package:ourjourneys/models/interface/actions_btn_model.dart';
import 'package:ourjourneys/shared/views/ui_consts.dart' show UiConsts;

/// display a popup menu with a list of actions
class MoreActionsBtn extends StatelessWidget {
  final List<ActionsBtnModel> actions;
  final Icon displayIcon;
  final String? tooltip;
  const MoreActionsBtn(
      {super.key,
      required this.actions,
      this.displayIcon = const Icon(
        Icons.menu_outlined,
      ),
      this.tooltip});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(
          borderRadius: UiConsts.BorderRadiusCircular_medium),
      position: PopupMenuPosition.under,
      icon: displayIcon,
      tooltip: tooltip,
      enableFeedback: true,
      onSelected: (String value) {
        _performSelectedValue(value);
      },
      itemBuilder: (BuildContext context) =>
          <PopupMenuEntry<String>>[..._createPopupMenuEntries()],
    );
  }

  List<PopupMenuEntry<String>> _createPopupMenuEntries() {
    return actions.map((ActionsBtnModel action) {
      return PopupMenuItem<String>(
        value: action.actionName,
        child: ListTile(
          shape: RoundedRectangleBorder(
              borderRadius: UiConsts.BorderRadiusCircular_medium),
          enableFeedback: true,
          leading: action.icon,
          title: Text(action.actionName),
          subtitle: action.actionDes != null ? Text(action.actionDes!) : null,
        ),
      );
    }).toList();
  }

  void _performSelectedValue(String value) {
    actions.firstWhere((action) => action.actionName == value).onPressed();
  }
}
