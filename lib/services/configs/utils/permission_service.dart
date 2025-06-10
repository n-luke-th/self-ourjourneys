/// lib/configs/permission_service.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_io/io.dart' show Platform;
import 'package:ourjourneys/shared/services/permission_enum.dart'
    show PermissionEnum;

/// Service to handle permissions
class PermissionsService {
  final List<Permission> _permissions = [
    if (Platform.isAndroid || Platform.isIOS) Permission.photos,
    if (Platform.isAndroid || Platform.isIOS) Permission.locationWhenInUse,
    if (Platform.isAndroid || Platform.isIOS) Permission.calendarFullAccess,
    if (Platform.isAndroid || Platform.isIOS) Permission.calendarWriteOnly,
    if (kIsWeb) Permission.location,
    Permission.notification,
  ];

  List<Permission> get permissionsList => _permissions;

  /// Requests the user for access to these permissions, if they haven't already been granted before.
  /// and return all permissions status as a [Map]
  Future<Map<Permission, PermissionStatus>> requestAndCheckPermissions() async {
    return await _permissions.request();
  }

  /// Requests the user for access to a specific permission, if they haven't already been granted before.
  Future<PermissionStatus> requestPermission(PermissionEnum permission) async {
    switch (permission) {
      case PermissionEnum.photos:
        if (kIsWeb) {
          _throwUnsupportedError(permission, isWeb: true);
          break;
        }
        return await Permission.photos.request();
      case PermissionEnum.locationWhenInUse:
        if (kIsWeb) {
          _throwUnsupportedError(permission, isWeb: true);
          break;
        }
        return await Permission.locationWhenInUse.request();
      case PermissionEnum.calendarFullAccess:
        if (kIsWeb) {
          _throwUnsupportedError(permission, isWeb: true);
          break;
        }
        return await Permission.calendarFullAccess.request();
      case PermissionEnum.calendarWriteOnly:
        if (kIsWeb) {
          _throwUnsupportedError(permission, isWeb: true);
          break;
        }
        return await Permission.calendarWriteOnly.request();
      case PermissionEnum.notifications:
        return await Permission.notification.request();
      case PermissionEnum.location:
        if (!kIsWeb) {
          _throwUnsupportedError(permission, isWeb: false);
          break;
        }
        return await Permission.location.request();
    }
    return PermissionStatus.denied;
  }

  /// get the [String] status of a specific permission based on the provided enum value
  String getStatusText(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Granted';
      case PermissionStatus.denied:
        return 'Denied';
      case PermissionStatus.permanentlyDenied:
        return 'Permanently Denied';
      case PermissionStatus.restricted:
        return 'Restricted';
      case PermissionStatus.limited:
        return "Limited";
      default:
        return 'Unknown';
    }
  }

  /// get the [String] name of a specific permission based on the provided [PermissionEnum]
  String getPermissionNameByEnum(PermissionEnum permission) {
    switch (permission) {
      case PermissionEnum.photos:
        return 'Photos';
      case PermissionEnum.locationWhenInUse:
        return 'Location (When in use)';
      case PermissionEnum.calendarFullAccess:
        return 'Calendar (Full Access)';
      case PermissionEnum.calendarWriteOnly:
        return 'Calendar (Write Only)';
      case PermissionEnum.notifications:
        return 'Notifications';
      case PermissionEnum.location:
        return 'Location';
    }
  }

  /// get the [String] name of a specific permission based on the provided [Permission]
  String getPermissionNameByPermission(Permission permission) {
    switch (permission) {
      case Permission.photos:
        return 'Photos';
      case Permission.locationWhenInUse:
        return 'Location (When in use)';
      case Permission.calendarFullAccess:
        return 'Calendar (Full Access)';
      case Permission.calendarWriteOnly:
        return 'Calendar (Write Only)';
      case Permission.notification:
        return 'Notifications';
      case Permission.location:
        return 'Location';
      default:
        return 'Unknown';
    }
  }

  /// Checks the status of a specific permission based on the provided enum value.
  Future<PermissionStatus> checkPermission(PermissionEnum permission) async {
    switch (permission) {
      case PermissionEnum.photos:
        if (kIsWeb) {
          _throwUnsupportedError(permission, isWeb: true);
          break;
        }
        return await Permission.photos.status;
      case PermissionEnum.locationWhenInUse:
        if (kIsWeb) {
          _throwUnsupportedError(permission, isWeb: true);
          break;
        }
        return await Permission.locationWhenInUse.status;
      case PermissionEnum.calendarFullAccess:
        if (kIsWeb) {
          _throwUnsupportedError(permission, isWeb: true);
          break;
        }
        return await Permission.calendarFullAccess.status;
      case PermissionEnum.calendarWriteOnly:
        if (kIsWeb) {
          _throwUnsupportedError(permission, isWeb: true);
          break;
        }
        return await Permission.calendarWriteOnly.status;
      case PermissionEnum.notifications:
        return await Permission.notification.status;
      case PermissionEnum.location:
        if (kIsWeb) {
          return await Permission.location.status;
        } else {
          _throwUnsupportedError(permission);
          break;
        }
    }
    return PermissionStatus.denied;
  }

  void _throwUnsupportedError(PermissionEnum permission, {bool isWeb = false}) {
    if (!isWeb) {
      throw UnsupportedError("Unsupported for permission : '$permission'");
    } else {
      throw UnsupportedError(
          "Unsupported for permission : '$permission' on web");
    }
  }
}
