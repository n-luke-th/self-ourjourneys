/// lib/errors/object_storage_exception/cloud_object_storage_exception.dart
/// Authentication-related exceptions
import 'package:xiaokeai/errors/base/base_exception.dart';

class CloudObjectStorageException extends BaseException {
  CloudObjectStorageException(
      {super.error,
      super.st,
      super.errorDetailsFromDependency,
      super.process,
      required super.errorEnum});
}
