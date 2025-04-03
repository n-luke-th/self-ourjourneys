/// lib/services/object_storage/cloud_object_storage_wrapper.dart
///
/// the cloud object storage wrapper functions
/// are the top-level functions that will perform
/// neccessary cloud object storage actions called when user trigger call to action btn (upload btn, download btn, etc.)

// TODO: localize this file

// ignore_for_file: use_build_context_synchronously

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'package:xiaokeai/helpers/dependencies_injection.dart';
import 'package:xiaokeai/helpers/logger_provider.dart';
import 'package:xiaokeai/l10n/generated/i18n/app_localizations.dart'
    show AppLocalizations;
import 'package:xiaokeai/services/notifications/notification_manager.dart';
import 'package:xiaokeai/services/notifications/notification_service.dart';
import 'package:xiaokeai/services/object_storage/cloud_object_storage_service.dart';
import 'package:xiaokeai/shared/common/file_picker_enum.dart';
import 'package:xiaokeai/shared/services/firebase_storage_enum.dart';

class CloudObjectStorageWrapper {
  final Logger _logger = locator<Logger>();
  final CloudObjectStorageService _cloudObjectStorageService =
      getIt<CloudObjectStorageService>();

  CloudObjectStorageWrapper();

  Future<PlatformFile?> handlePickImageOrFile(context,
      {FilePickerMode pickerMode = FilePickerMode.photoPicker}) async {
    PlatformFile? file;
    try {
      file = await _cloudObjectStorageService.pickImageOrFile(pickerMode);
    } on PlatformException catch (e) {
      context.read<NotificationManager>().showNotification(
          context,
          NotificationData(
              title: 'Failed: [${e.code}]',
              message: e.message ??
                  "Unexpected error occurred, likely is denied permission!",
              type: CustomNotificationType.error));
      rethrow;
    } catch (e) {
      context.read<NotificationManager>().showNotification(
          context,
          NotificationData(
              title: 'Failed',
              message: e.toString(),
              type: CustomNotificationType.error));
      rethrow;
    }
    if (file != null) {
      return file;
    } else {
      return null;
    }
  }

  /// returns `[path, downloadUrl]`
  Future<List<String>?> handlePickAndUploadFile(BuildContext context,
      {FilePickerMode? pickerMode = FilePickerMode.photoPicker,
      FirebaseStoragePaths? firebaseStoragePath =
          FirebaseStoragePaths.userContent}) async {
    try {
      final file =
          await _cloudObjectStorageService.pickImageOrFile(pickerMode!);
      if (file != null) {
        final uploadResult = await _cloudObjectStorageService.uploadFile(
            'uploads/${file.name}', file,
            firebaseStoragePath: firebaseStoragePath);
        final path = uploadResult[0];
        final url = uploadResult[1];
        _logger.d('File "$path" uploaded successfully. URL: $url');
        context.read<NotificationManager>().showNotification(
            context,
            NotificationData(
                title: AppLocalizations.of(context)!.success,
                message: "File uploaded!",
                type: CustomNotificationType.success));
        return [path, url];
      }
    } on PlatformException catch (e) {
      context.read<NotificationManager>().showNotification(
          context,
          NotificationData(
              title: 'Failed: [${e.code}]',
              message: e.message ??
                  "Unexpected error occurred, likely is denied permission!",
              type: CustomNotificationType.error));
      rethrow;
    } catch (e) {
      context.read<NotificationManager>().showNotification(
          context,
          NotificationData(
              title: 'Failed',
              message: e.toString(),
              type: CustomNotificationType.error));
      rethrow;
    }
    return null;
  }

  /// returns `[path, downloadUrl]`
  Future<List<String>?> handleUploadFile(
      BuildContext context, PlatformFile? file,
      {FilePickerMode? pickerMode = FilePickerMode.photoPicker,
      FirebaseStoragePaths? firebaseStoragePath =
          FirebaseStoragePaths.userContent,
      bool showNotification = true}) async {
    try {
      if (file != null) {
        _logger.d("uploading file: ${file.name}");
        final uploadResult = await _cloudObjectStorageService.uploadFile(
            'uploads/${file.name}', file,
            firebaseStoragePath: firebaseStoragePath);
        final path = uploadResult[0];
        final url = uploadResult[1];
        _logger.d('File "$path" uploaded successfully. URL: $url');
        if (showNotification) {
          context.read<NotificationManager>().showNotification(
              context,
              NotificationData(
                  title: AppLocalizations.of(context)!.success,
                  message: "File uploaded!",
                  type: CustomNotificationType.success));
        }
        return [path, url];
      }
    } on PlatformException catch (e) {
      if (showNotification) {
        context.read<NotificationManager>().showNotification(
            context,
            NotificationData(
                title: 'Failed: [${e.code}]',
                message: e.message ??
                    "Unexpected error occurred, likely is denied permission!",
                type: CustomNotificationType.error));
      }
      rethrow;
    } catch (e) {
      if (showNotification) {
        context.read<NotificationManager>().showNotification(
            context,
            NotificationData(
                title: 'Failed',
                message: e.toString(),
                type: CustomNotificationType.error));
      }
      rethrow;
    }
    return null;
  }

  Future<void> handleDeleteFile(BuildContext context, String? path,
      {FirebaseStoragePaths? firebaseStoragePath =
          FirebaseStoragePaths.userContent}) async {
    if (path == null) {
      context.read<NotificationManager>().showNotification(
          context,
          NotificationData(
              title: 'Failed',
              message: "No file selected to delete",
              type: CustomNotificationType.error));
    }
    try {
      await _cloudObjectStorageService.deleteFile(path!,
          firebaseStoragePath: firebaseStoragePath!);
      context.read<NotificationManager>().showNotification(
          context,
          NotificationData(
              title: 'Success',
              message: "File deleted!",
              type: CustomNotificationType.success));
    } catch (e) {
      context.read<NotificationManager>().showNotification(
          context,
          NotificationData(
              title: 'Failed',
              message: e.toString(),
              type: CustomNotificationType.error));
      rethrow;
    }
  }

  Future<void> handleDeleteAllFilesInFolder(BuildContext context,
      {FirebaseStoragePaths? firebaseStoragePath =
          FirebaseStoragePaths.userContent,
      bool showNotification = true}) async {
    try {
      if (showNotification) {
        await _cloudObjectStorageService.deleteAllFilesInFolder(
            firebaseStoragePath: firebaseStoragePath!);
        context.read<NotificationManager>().showNotification(
            context,
            NotificationData(
                title: AppLocalizations.of(context)!.success,
                message: "File(s) deleted!",
                type: CustomNotificationType.success));
      }
    } catch (e) {
      if (showNotification) {
        context.read<NotificationManager>().showNotification(
            context,
            NotificationData(
                title: AppLocalizations.of(context)!.failed,
                message: e.toString(),
                type: CustomNotificationType.error));
      }
      rethrow;
    }
  }
}
