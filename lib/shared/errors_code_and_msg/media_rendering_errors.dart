/// lib/shared/errors_code_and_msg/media_rendering_errors.dart
///
/// pairs of global error code and msg for media rendering related
// ignore_for_file: constant_identifier_names

import 'package:ourjourneys/errors/base/base_error_enum.dart';

/// This enum contains key-value pairs for [MediaRenderingException]
///
/// which key is used for error code
///
/// and value is the error msg
enum MediaRenderingErrors implements ErrorType {
  // Client-side errors (MDRD_C)
  ///
  /// The provided object is not valid.
  MDRD_C01('The provided object is not valid.'),

  ///  The provided object is too large.
  MDRD_C02('The provided object is too large.'),

  /// Invalid object extension, object extension is not supported.
  MDRD_C03('Invalid object extension, object extension is not supported.'),

  // Server-side errors (MDRD_S)

  /// Failed to load the object from the original source.'
  MDRD_S01('Failed to load the image from the original source.'),

  // unknown/unsure origin errors (MDRD_U)

  /// Something went wrong, please try again.
  MDRD_U00('Something went wrong, please try again.');

  final String msg;

  const MediaRenderingErrors(this.msg);

  /// Get the error code (e.g., 'MDRD_S01')
  @override
  String get code => name;

  /// Get the error message
  @override
  String get message => msg;

  /// Find an [MediaRenderingErrors] instance by its error code
  static MediaRenderingErrors? fromCode(String code) {
    try {
      return MediaRenderingErrors.values
          .firstWhere((error) => error.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Find an [MediaRenderingErrors] instance by its error message
  static MediaRenderingErrors? fromMessage(String message) {
    try {
      return MediaRenderingErrors.values
          .firstWhere((error) => error.message == message);
    } catch (e) {
      return null;
    }
  }
}
