/// lib/errors/object_storage_exception/cloud_object_storage_exception.dart
/// Cloud object-related exceptions
import 'package:ourjourneys/errors/base/base_exception.dart';

class CloudObjectStorageException extends BaseException {
  CloudObjectStorageException(
      {super.error,
      super.st,
      super.errorDetailsFromDependency,
      super.process,
      required super.errorEnum});
}
