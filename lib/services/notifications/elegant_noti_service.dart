/// lib/services/notifications/elegant_noti_service.dart
///
/// a notification class of elegant notification
/// config how elegant noti will look here

import 'package:elegant_notification/resources/arrays.dart';
import 'package:elegant_notification/resources/stacked_options.dart';
import 'package:flutter/material.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:ourjourneys/services/notifications/notification_service.dart';
import 'package:ourjourneys/shared/views/ui_consts.dart';

class ElegantNotificationService implements NotificationService {
  @override
  void showNotification(
    BuildContext context,
    NotificationData data,
  ) {
    ElegantNotification(
            title: Text(
              data.title,
              style:
                  TextStyle(color: Theme.of(context).colorScheme.onSecondary),
            ),
            description: Text(data.message,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary)),
            borderRadius: UiConsts.BorderRadiusCircular_standard,
            icon: Icon(_getIcon(data.type), color: _getColor(data.type)),
            toastDuration: data.duration,
            animationDuration: const Duration(milliseconds: 300),
            position: data.position,
            animation: AnimationType.fromTop,
            displayCloseButton: data.showCloseBtn,
            progressBarPadding: UiConsts.PaddingAll_standard,
            shadow: BoxShadow(
                color: Theme.of(context).dialogTheme.backgroundColor!,
                blurRadius: UiConsts.borderRadius),
            stackedOptions: StackedOptions(
                scaleFactor: BorderSide.strokeAlignCenter, key: 'stack_'),
            progressIndicatorBackground:
                Theme.of(context).colorScheme.secondary,
            progressIndicatorColor: Theme.of(context).colorScheme.onSecondary,
            background: data.backgroundColor == null
                ? Theme.of(context).colorScheme.secondaryContainer
                : data.backgroundColor!)
        .show(context);
  }

  Color _getColor(CustomNotificationType type) {
    switch (type) {
      case CustomNotificationType.success:
        return Colors.green;
      case CustomNotificationType.error:
        return Colors.red;
      case CustomNotificationType.info:
        return Colors.blue;
      case CustomNotificationType.warning:
        return Colors.orange;
    }
  }

  // String _getTitle(CustomNotificationType type) {
  //   switch (type) {
  //     case CustomNotificationType.success:
  //       return 'Success';
  //     case CustomNotificationType.error:
  //       return 'Error';
  //     case CustomNotificationType.info:
  //       return 'Information';
  //     case CustomNotificationType.warning:
  //       return "Warning";
  //   }
  // }

  IconData _getIcon(CustomNotificationType type) {
    switch (type) {
      case CustomNotificationType.success:
        return Icons.check_circle;
      case CustomNotificationType.error:
        return Icons.error;
      case CustomNotificationType.info:
        return Icons.info;
      case CustomNotificationType.warning:
        return Icons.warning_rounded;
    }
  }
}
