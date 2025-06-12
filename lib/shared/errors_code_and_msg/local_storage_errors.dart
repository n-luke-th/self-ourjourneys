/// lib/shared/errors_code_and_msg/local_storage_errors.dart
///
/// pairs of global error code and msg for local storage related
// ignore_for_file: constant_identifier_names

import 'package:ourjourneys/errors/base/base_error_enum.dart';

/// This enum contains key-value pairs for [LocalStorageException]
///
/// which key is used for error code
///
/// and value is the error msg
enum LocalStorageErrors implements ErrorType {
  // Client-side errors (LOCS_C)
  ///
  /// The provided object is not valid.
  LOCS_C01('The provided object is not valid.'),

  ///  The provided object is too large.
  LOCS_C02('The provided object is too large.'),

  /// Invalid object extension, object extension is not supported.
  LOCS_C03('Invalid object extension, object extension is not supported.'),

  // Server-side errors (LOCS_S)

  /// Failed to load the object from the local storage.
  LOCS_S01('Failed to load the object from the local storage.'),

  // unknown/unsure origin errors (LOCS_U)

  /// Something went wrong, please try again.
  LOCS_U00('Something went wrong, please try again.');

  final String msg;

  const LocalStorageErrors(this.msg);

  /// Get the error code (e.g., 'LOCS_S01')
  @override
  String get code => name;

  /// Get the error message
  @override
  String get message => msg;

  /// Find an [LocalStorageErrors] instance by its error code
  static LocalStorageErrors? fromCode(String code) {
    try {
      return LocalStorageErrors.values
          .firstWhere((error) => error.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Find an [LocalStorageErrors] instance by its error message
  static LocalStorageErrors? fromMessage(String message) {
    try {
      return LocalStorageErrors.values
          .firstWhere((error) => error.message == message);
    } catch (e) {
      return null;
    }
  }
}
