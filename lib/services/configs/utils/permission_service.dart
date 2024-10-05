/// lib/configs/permission_service.dart

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_io/io.dart';
import 'package:xiaokeai/shared/services/permission_enum.dart';

class PermissionsService {
  final List<Permission> _permissions = [
    if (Platform.isAndroid || Platform.isIOS) Permission.photos,
    if (Platform.isAndroid || Platform.isIOS) Permission.locationWhenInUse,
    if (Platform.isAndroid || Platform.isIOS) Permission.calendarFullAccess,
    if (Platform.isAndroid || Platform.isIOS) Permission.calendarWriteOnly,
    Permission.notification,
  ];

  List<Permission> get permissionsList => _permissions;

  Future<Map<Permission, PermissionStatus>> checkPermissions() async {
    return await _permissions.request();
  }

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

  /// Checks the status of a specific permission based on the provided enum value.
  Future<PermissionStatus> checkPermission(PermissionConst permission) async {
    switch (permission) {
      case PermissionConst.photos:
        if (kIsWeb) {
          throw UnsupportedError(
              'Unsupported on web for permission : $permission');
        }
        return await Permission.photos.status;
      case PermissionConst.locationWhenInUse:
        if (kIsWeb) {
          throw UnsupportedError(
              'Unsupported on web for permission : $permission');
        }
        return await Permission.locationWhenInUse.status;
      case PermissionConst.calendarFullAccess:
        if (kIsWeb) {
          throw UnsupportedError(
              'Unsupported on web for permission : $permission');
        }
        return await Permission.calendarFullAccess.status;
      case PermissionConst.calendarWriteOnly:
        if (kIsWeb) {
          throw UnsupportedError(
              'Unsupported on web for permission : $permission');
        }
        return await Permission.calendarWriteOnly.status;
      case PermissionConst.notifications:
        return await Permission.notification.status;
      default:
        throw ArgumentError('Unsupported permission: $permission');
    }
  }
}
