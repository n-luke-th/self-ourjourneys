/// lib/errors/base/base_error_enum.dart
///
/// error format: `4:1:3`
///
/// error format explaination: `4` for error category,
/// `1` is just a divider between category and `error term` that character `_` will be used,
/// and `3` is `error term` that can divided into 2 parts where
/// first letter is where error is likely originated.
///
/// (`C` for client side error, `S` for server side error, `U` for unknown/unsure origin)
///
/// while another part is just a number (00 - 99) indicates different errors
///
/// for example, `AUTH_C01` is the authentication error where
/// its value of this code is 'The provided email address is not valid.'
///

// ignore_for_file: constant_identifier_names

/// Abstract base class for error types
abstract class ErrorType {
  /// The error code
  String get code;

  /// The error message
  String get message;

  /// Find an ErrorType instance by its error code
  static ErrorType? fromCode(String code) {
    throw UnimplementedError("Subclasses must implement 'fromCode'");
  }

  /// Find an ErrorType instance by its error message
  static ErrorType? fromMessage(String message) {
    throw UnimplementedError("Subclasses must implement 'fromMessage'");
  }
}
