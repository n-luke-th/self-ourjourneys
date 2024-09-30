/// lib/errors/base_exception.dart
///
/// base class for global error exception
import 'package:logger/logger.dart';
import 'package:xiaokeai/errors/base/base_error_enum.dart';
import 'package:xiaokeai/helpers/logger_provider.dart';

class BaseException implements Exception {
  final ErrorType errorEnum;
  // final String message;
  final Logger _logger = locator<Logger>();
  final String? errorDetailsFromDependency;
  final Object? error;
  final StackTrace? st;

  BaseException(
      {required this.errorEnum,
      // required this.message,
      this.error,
      this.st,
      this.errorDetailsFromDependency}) {
    _logError(
      code: errorEnum.code,
      message: errorEnum.message,
      extDetails: errorDetailsFromDependency,
      error: error,
      st: st ?? StackTrace.current,
    );
  }

  @override
  String toString() {
    return "${runtimeType.toString().split('.').last}:\n ${errorEnum.code}: ${errorEnum.message}";
  }

  void _logError(
      {required String code,
      String? message,
      String? extDetails,
      required Object? error,
      required StackTrace? st}) {
    _logger.e(
        "Error thrown from '${runtimeType.toString().split('.').last}' -> '$code' : '${message ?? ''}'\n [Extended details: '${extDetails ?? 'null'}']",
        error: error,
        stackTrace: st ?? StackTrace.current);
  }
}
