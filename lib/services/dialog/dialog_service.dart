/// lib/services/dialog/dialog_service.dart
///
/// a dialog service

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ourjourneys/shared/views/ui_consts.dart';

enum DialogType {
  confirmation,
  information,
  warning,
  error,
  input,
}

class DialogButton {
  final String text;
  final VoidCallback onPressed;
  final bool isDestructive;

  DialogButton({
    required this.text,
    required this.onPressed,
    this.isDestructive = false,
  });
}

class DialogService {
  static Future<T?> showCustomDialog<T>(
    BuildContext context, {
    required DialogType type,
    required String title,
    required String message,
    List<DialogButton>? buttons,
    TextEditingController? inputController,
    String? inputHint,
    String? inputLabel,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: UiConsts.BorderRadiusCircular_standard),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: _buildDialogContent(
              context, type, message, inputController, inputHint, inputLabel),
          actions: buttons
                  ?.map((button) => _buildDialogButton(context, button))
                  .toList() ??
              [
                _buildDialogButton(
                    context,
                    DialogButton(
                        text: "OK",
                        onPressed: () => Navigator.of(context).pop()))
              ],
        );
      },
    );
  }

  static Widget _buildDialogContent(
      BuildContext context,
      DialogType type,
      String message,
      TextEditingController? inputController,
      String? inputHint,
      String? inputLabel) {
    switch (type) {
      case DialogType.input:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 16),
            TextField(
              controller: inputController,
              decoration: InputDecoration(
                hintText: inputHint,
                labelText: inputLabel,
              ),
            ),
          ],
        );
      default:
        return Text(message);
    }
  }

  static Widget _buildDialogButton(BuildContext context, DialogButton button) {
    return button.isDestructive
        ? ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: UiConsts.BorderRadiusCircular_standard),
            ),
            onPressed: button.onPressed,
            child: Text(
              button.text,
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          )
        : TextButton(
            onPressed: button.onPressed,
            child: Text(
              button.text,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
  }

  static Future<bool?> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText = 'OK',
    String? cancelText = 'CANCEL',
  }) {
    return showCustomDialog<bool>(
      context,
      type: DialogType.confirmation,
      title: title,
      message: message,
      buttons: [
        DialogButton(
          text: cancelText!,
          onPressed: () => context.pop(false),
        ),
        DialogButton(
          text: confirmText!,
          onPressed: () => context.pop(true),
          isDestructive: true,
        ),
      ],
    );
  }

  static Future<bool?> showInfoDialog({
    required BuildContext context,
    required String title,
    required String message,
    String? acknowledgeText = 'ACKNOWLEDGE',
  }) {
    return showCustomDialog<bool>(
      context,
      type: DialogType.information,
      title: title,
      message: message,
      buttons: [
        DialogButton(
          text: acknowledgeText!,
          onPressed: () => context.pop(true),
          isDestructive: true,
        ),
      ],
    );
  }
}
