/// lib/services/notifications/notification_factory.dart
///
/// a factory class of notification service
import 'package:ourjourneys/services/notifications/elegant_noti_service.dart';
import 'package:ourjourneys/services/notifications/notification_service.dart';

enum NotificationStyle { elegant }

class NotificationFactory {
  static NotificationService createNotificationService(
      NotificationStyle style) {
    switch (style) {
      case NotificationStyle.elegant:
        return ElegantNotificationService();
    }
  }
}
