/// lib/errors/auth_exception/auth_exception.dart
/// Authentication-related exceptions
import 'package:ourjourneys/errors/base/base_exception.dart';

class AuthException extends BaseException {
  AuthException(
      {super.error,
      super.st,
      super.errorDetailsFromDependency,
      super.process,
      required super.errorEnum});
}
