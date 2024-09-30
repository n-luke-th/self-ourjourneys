/// lib/shared/errors_code_and_msg/auth_errors.dart
///
/// pairs of global error code and msg for authentication related
// ignore_for_file: constant_identifier_names

import 'package:xiaokeai/errors/base/base_error_enum.dart';

/// This enum contains key-value pairs for `AuthErrors`
///
/// which key is used for error code
///
/// and value is the error msg
enum AuthErrors implements ErrorType {
  // Client-side errors (AUTH_C)

  /// The provided email address is not valid.
  AUTH_C01('The provided email address is not valid.'),

  /// The password provided is too weak.
  AUTH_C02('The password provided is too weak.'),

  /// There is already an account exists with this email.
  AUTH_C03('There is already an account exists with this email.'),

  /// Given credential is incorrect, malformed or has expired.
  AUTH_C04('Given credential is incorrect, malformed or has expired.'),

  /// No user found with provided credentials.
  AUTH_C05('No user found with provided credentials'),

  /// Wrong password provided.
  AUTH_C06('Wrong password provided.'),

  /// Too many attempts. Please try again later.
  AUTH_C07('Too many attempts. Please try again later.'),

  /// The verification code of the credential is not valid.
  AUTH_C08('The verification code of the credential is not valid.'),

  /// The provided email address is not valid (alternative message).
  AUTH_C09('The provided email address is not valid.'),

  /// No user account found that is associated with the provided email address.
  AUTH_C10(
      'No user account found that is associated with the provided email address'),

  /// User is required to verify their identity before proceeding.
  AUTH_C11('You are required to verify your identity before process.'),

  // Server-side errors (AUTH_S)

  /// The requested operation is not allowed.
  AUTH_S01('The requested operation is not allowed'),

  /// This account is currently disabled, please contact our support.
  AUTH_S02('This account is currently disabled, please contact our support.'),

  /// An Android package name must be provided if the Android app is required to be installed.
  AUTH_S03(
      'An Android package name must be provided if the Android app is required to be installed.'),

  /// A continue URL must be provided in the request.
  AUTH_S04('A continue URL must be provided in the request.'),

  /// An iOS Bundle ID must be provided if an App Store ID is provided.
  AUTH_S05('An iOS Bundle ID must be provided if an App Store ID is provided.'),

  /// The continue URL provided in the request is invalid.
  AUTH_S06('The continue URL provided in the request is invalid.'),

  /// The domain of the continue URL is not whitelisted. Whitelist the domain in the Firebase console.
  AUTH_S07(
      'The domain of the continue URL is not whitelisted. Whitelist the domain in the Firebase console.'),

  /// Given code has expired.
  AUTH_S08('Given code has expired.'),

  /// Given code is invalid, likely the code is malformed or has already been used.
  AUTH_S09(
      'Given code is invalid, likely the code is malformed or has already been used'),

  // unknown/unsure origin errors (AUTH_U)

  /// Something went wrong, please try again.
  AUTH_U00('Something went wrong, please try again.');

  final String msg;

  const AuthErrors(this.msg);

  /// Get the error code (e.g., 'AUTH_C01')
  @override
  String get code => name;

  /// Get the error message
  @override
  String get message => msg;

  /// Find an AuthErrors instance by its error code
  static AuthErrors? fromCode(String code) {
    try {
      return AuthErrors.values.firstWhere((error) => error.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Find an AuthErrors instance by its error message
  static AuthErrors? fromMessage(String message) {
    try {
      return AuthErrors.values.firstWhere((error) => error.message == message);
    } catch (e) {
      return null;
    }
  }
}
