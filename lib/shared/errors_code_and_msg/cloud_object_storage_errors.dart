/// lib/shared/errors_code_and_msg/cloud_object_storage_errors.dart
///
/// pairs of global error code and msg for cloud object storage related
// ignore_for_file: constant_identifier_names

import 'package:ourjourneys/errors/base/base_error_enum.dart';

/// This enum contains key-value pairs for [CloudObjectStorageErrors]
///
/// which key is used for error code
///
/// and value is the error msg
enum CloudObjectStorageErrors implements ErrorType {
  // Client-side errors (CLOS_C)
  ///
  /// The provided object is not valid.
  CLOS_C01('The provided object is not valid.'),

  ///  The provided object is too large.
  CLOS_C02('The provided object is too large.'),

  /// Invalid object key, same object already exists or incorrect object key format.
  CLOS_C03(
      'Invalid object key, same object already exists or incorrect object key format.'),

  /// Invalid object extension, object extension is not supported.
  CLOS_C04('Invalid object extension, object extension is not supported.'),

  /// Network error, please check your network connection.
  CLOS_C05('Network error, please check your network connection.'),

  // Server-side errors (CLOS_S)

  /// Failed to load the object from the cloud object storage.
  CLOS_S01('Failed to load the object from the cloud object storage.'),

  /// Invalid HTTP response from server, please try again later.
  CLOS_S02('Invalid HTTP response from server, please try again later.'),

  // unknown/unsure origin errors (CLOS_U)

  /// Something went wrong, please try again.
  CLOS_U00('Something went wrong, please try again.');

  final String msg;

  const CloudObjectStorageErrors(this.msg);

  /// Get the error code (e.g., 'CLOS_S01')
  @override
  String get code => name;

  /// Get the error message
  @override
  String get message => msg;

  /// Find an [CloudObjectStorageErrors] instance by its error code
  static CloudObjectStorageErrors? fromCode(String code) {
    try {
      return CloudObjectStorageErrors.values
          .firstWhere((error) => error.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Find an [CloudObjectStorageErrors] instance by its error message
  static CloudObjectStorageErrors? fromMessage(String message) {
    try {
      return CloudObjectStorageErrors.values
          .firstWhere((error) => error.message == message);
    } catch (e) {
      return null;
    }
  }
}
