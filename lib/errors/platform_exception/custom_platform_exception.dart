/// lib/errors/platform_exception/custom_platform_exception.dart
///
///
/// Platform-related exceptions
import 'package:xiaokeai/errors/base_exception.dart';

class CustomPlatformException extends BaseException {
  CustomPlatformException({
    required super.code,
    required super.message,
    super.error,
    super.st,
    super.errorDetailsFromDependency,
  });
}
