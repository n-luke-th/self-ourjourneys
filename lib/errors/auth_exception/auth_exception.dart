/// lib/errors/auth_exception/auth_exception.dart
/// Authentication-related exceptions
import 'package:xiaokeai/errors/base/base_exception.dart';

class AuthException extends BaseException {
  AuthException(
      {super.error,
      super.st,
      super.errorDetailsFromDependency,
      required super.errorEnum});
}
