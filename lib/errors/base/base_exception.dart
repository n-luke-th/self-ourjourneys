/// lib/errors/base_exception.dart
///
/// base class for global error exception
import 'package:logger/logger.dart';
import 'package:xiaokeai/errors/base/base_error_enum.dart';
import 'package:xiaokeai/helpers/logger_provider.dart';

abstract class BaseException implements Exception {
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

  /// returns the full error string with useful details that possibly get
  String getFullErrorString() {
    return "Error thrown from '${runtimeType.toString().split('.').last}' -> '${errorEnum.code}' : '${errorEnum.message}'\n [Extended details: '${errorDetailsFromDependency ?? 'Null'}']";
  }

  @override

  /// returns the code and its msg in the following format
  ///
  /// `${code}: ${msg}`
  String toString() {
    return "${errorEnum.code}: ${errorEnum.message}";
  }

  void _logError(
      {required String code,
      String? message,
      String? extDetails,
      required Object? error,
      required StackTrace? st}) {
    _logger.e(
        "Error thrown from '${runtimeType.toString().split('.').last}' -> '$code' : '${message ?? ''}'\n [Extended details: '${error.runtimeType.toString().split('.').lastOrNull}' -> '${extDetails ?? 'Null'}']",
        error: error,
        stackTrace: st ?? StackTrace.current);
  }
}
