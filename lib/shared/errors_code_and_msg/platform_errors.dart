/// lib/shared/errors_code_and_msg/platform_errors.dart
///
/// pairs of global error code and msg for platform related
// ignore_for_file: constant_identifier_names

import 'package:ourjourneys/errors/base/base_error_enum.dart';

/// This enum contains key-value pairs for [CustomPlatformException]
///
/// which key is used for error code
///
/// and value is the error msg
enum PlatformErrors implements ErrorType {
  // Client-side errors (PLAT_C)
  ///
  /// Unsupported platform, accessing platform-specific feature that's not available on the current device or OS version.
  PLAT_C01(
      "Unsupported platform, accessing platform-specific feature that's not available on the current device or OS version."),

  ///  Missing required permission(s).
  PLAT_C02('Missing required permission(s).'),

  // Server-side errors (PLAT_S)

  /// Native code issues/Internal code issues.
  PLAT_S01('Native code issues/Internal code issues.'),

  // unknown/unsure origin errors (PLAT_U)

  /// Something went wrong, please try again.
  PLAT_U00('Something went wrong, please try again.');

  final String msg;

  const PlatformErrors(this.msg);

  /// Get the error code (e.g., 'PLAT_S01')
  @override
  String get code => name;

  /// Get the error message
  @override
  String get message => msg;

  /// Find an [PlatformErrors] instance by its error code
  static PlatformErrors? fromCode(String code) {
    try {
      return PlatformErrors.values.firstWhere((error) => error.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Find an [PlatformErrors] instance by its error message
  static PlatformErrors? fromMessage(String message) {
    try {
      return PlatformErrors.values
          .firstWhere((error) => error.message == message);
    } catch (e) {
      return null;
    }
  }
}
