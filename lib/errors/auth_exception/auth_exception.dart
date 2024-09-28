/// lib/errors/auth_exception/auth_exception.dart
/// Authentication-related exceptions
import 'package:xiaokeai/errors/base_exception.dart';

class AuthException extends BaseException {
  AuthException(
      {required super.code,
      required super.message,
      super.error,
      super.st,
      super.errorDetailsFromDependency});
}
