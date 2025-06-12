/// lib/errors/local_storage_exception/local_storage_exception.dart
/// local object related exceptions
import 'package:ourjourneys/errors/base/base_exception.dart';

/// exception for local object related errors
class LocalStorageException extends BaseException {
  LocalStorageException(
      {super.error,
      super.st,
      super.errorDetailsFromDependency,
      super.process,
      required super.errorEnum});
}
