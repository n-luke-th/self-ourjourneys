/// lib/errors/base_exception.dart
///

import 'package:logger/logger.dart' show Logger;
import 'package:ourjourneys/errors/base/base_error_enum.dart';
import 'package:ourjourneys/helpers/dependencies_injection.dart' show getIt;

/// base class for global error exception
abstract class BaseException implements Exception {
  final ErrorType errorEnum;
  final String? process;
  final Logger _logger = getIt<Logger>();
  final String? errorDetailsFromDependency;
  final Object? error;
  final StackTrace? st;

  BaseException(
      {required this.errorEnum,
      this.process,
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
    String returnedString =
        "Error thrown from '${runtimeType.toString().split('.').last}' -> '${errorEnum.code}' : '${errorEnum.message}'\n [Extended details: '${errorDetailsFromDependency ?? 'Null'}']";
    if (process != null) {
      returnedString = "During '$process process' attempt, $returnedString";
    }

    return returnedString;
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
    String logString =
        "Error thrown from '${runtimeType.toString().split('.').last}' -> '$code' : '${message ?? ''}'\n [Extended details: '${error.runtimeType.toString().split('.').lastOrNull}' -> '${extDetails ?? 'Null'}']";
    if (process != null) {
      logString = "During '$process process' attempt, $logString";
    }

    _logger.e(logString, error: error, stackTrace: st ?? StackTrace.current);
  }
}
