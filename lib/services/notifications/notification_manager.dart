/// lib/services/notifications/notification_manager.dart
///
/// notification manager that control the notification to be displayed or not
///
///
import 'package:flutter/material.dart';
import 'package:ourjourneys/services/configs/settings_service.dart';
import 'package:ourjourneys/services/notifications/notification_factory.dart';
import 'package:ourjourneys/services/notifications/notification_service.dart';

class NotificationManager {
  final SettingsService _settingsService;
  late NotificationService _notificationService;

  NotificationManager(this._settingsService) {
    _notificationService = NotificationFactory.createNotificationService(
        NotificationStyle.elegant);
    _settingsService.addListener(_updateNotificationService);
  }

  void _updateNotificationService() {
    _notificationService = NotificationFactory.createNotificationService(
        NotificationStyle.elegant);
  }

  void showNotification(BuildContext context, NotificationData data) {
    _notificationService.showNotification(context, data);
  }

  void dispose() {
    _settingsService.removeListener(_updateNotificationService);
  }
}
