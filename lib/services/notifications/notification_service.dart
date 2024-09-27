/// lib/services/notifications/notification_service.dart
/// an abstract class of notification service

import 'package:flutter/material.dart';
import 'package:elegant_notification/resources/arrays.dart';

abstract class NotificationService {
  void showNotification(BuildContext context, NotificationData data);
}

class NotificationData {
  final String title;
  final String message;
  final CustomNotificationType type;
  final Duration duration;
  final Alignment position;
  final AnimationType animation;
  final bool showCloseBtn;
  final Color? backgroundColor;

  NotificationData({
    this.backgroundColor,
    this.showCloseBtn = true,
    this.position = Alignment.topCenter,
    this.animation = AnimationType.fromTop,
    required this.title,
    required this.message,
    required this.type,
    this.duration = const Duration(seconds: 5),
  });
}

enum CustomNotificationType { success, error, info, warning }
