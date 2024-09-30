/// lib/errors/platform_exception/custom_platform_exception.dart
///
///
/// Platform-related exceptions
import 'package:xiaokeai/errors/base/base_exception.dart';

class CustomPlatformException extends BaseException {
  CustomPlatformException({
    super.error,
    super.st,
    super.errorDetailsFromDependency,
    required super.errorEnum,
  });
}
