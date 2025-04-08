/// lib/services/object_storage/cloud_object_storage_wrapper.dart
///
/// the cloud object storage wrapper functions
/// are the top-level functions that will perform
/// neccessary cloud object storage actions called when user trigger call to action btn (upload btn, download btn, etc.)

// ignore_for_file: use_build_context_synchronously

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'package:ourjourneys/helpers/dependencies_injection.dart';
import 'package:ourjourneys/services/notifications/notification_manager.dart';
import 'package:ourjourneys/services/notifications/notification_service.dart';
import 'package:ourjourneys/services/object_storage/cloud_object_storage_service.dart';
import 'package:ourjourneys/shared/common/file_picker_enum.dart';

class CloudObjectStorageWrapper {
  final Logger _logger = getIt<Logger>();
  final CloudObjectStorageService _cloudObjectStorageService =
      getIt<CloudObjectStorageService>();
}
