// ignore_for_file: unused_element_parameter

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:ourjourneys/helpers/dependencies_injection.dart';
import 'package:ourjourneys/services/auth/acc/auth_service.dart';
import 'package:ourjourneys/shared/services/api_const.dart';
import 'package:ourjourneys/errors/auth_exception/auth_exception.dart';
import 'package:ourjourneys/shared/errors_code_and_msg/auth_errors.dart';
import 'package:logger/logger.dart';
import 'dart:math';

class DioHandler {
  final Dio _baseDio;
  final AuthService _auth = getIt<AuthService>();
  final Logger _logger = getIt<Logger>();

  DioHandler(Dio dio) : _baseDio = dio {
    // Only add logger once to base instance
    _baseDio.interceptors.addAll([
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: false,
        error: true,
        compact: true,
      ),
      _RetryInterceptor(),
    ]);

    // Set base URL and timeouts on baseDio
    _baseDio.options.baseUrl = ApiConsts.apiBaseUrl;
    _baseDio.options.connectTimeout = const Duration(seconds: 10);
    _baseDio.options.receiveTimeout = const Duration(seconds: 10);
  }

  /// Get a fresh Dio client with optional auth and contentType
  Future<Dio> getClient({
    bool withAuth = true,
    String? contentType,
  }) async {
    // Create a new Dio instance with the same options as the baseDio
    final Dio dio = Dio()
      ..options = _baseDio.options.copyWith()
      ..interceptors.addAll(_baseDio.interceptors);

    _logger.i('Getting new Dio client with auth: $withAuth');

    if (withAuth) {
      if (!_auth.isUserLoggedIn()) {
        throw AuthException(
          errorEnum: AuthErrors.AUTH_C12,
          errorDetailsFromDependency: 'User not authenticated',
          st: StackTrace.current,
        );
      }

      final token = await _auth.authInstance!.currentUser!.getIdToken();
      contentType ??= ApiConsts.headerContentTypeJson;

      dio.options.headers = {
        ApiConsts.headerAuthorization:
            '${ApiConsts.headerAuthorizationBearer} $token',
        ApiConsts.headerContentType: contentType,
      };
    } else {
      if (contentType != null) {
        dio.options.headers = {
          ApiConsts.headerContentType: contentType,
        };
      }
    }

    return dio;
  }

  // Create a `CancelToken` for canceling requests
  CancelToken getCancelToken() => CancelToken();
}

class _RetryInterceptor extends Interceptor {
  final Logger logger = getIt<Logger>();
  int maxRetries;
  int baseDelay;
  int jitter;

  _RetryInterceptor(
      {this.maxRetries = 2, this.baseDelay = 500, this.jitter = 300});

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;

    int retryCount = options.extra['retryCount'] ?? 0;

    if (_shouldRetry(err) && retryCount < maxRetries) {
      retryCount++;
      options.extra['retryCount'] = retryCount;

      final waitTime = _calculateBackoff(retryCount);
      logger.w(
          "Retrying request attempt '$retryCount': [${options.uri}] in ${waitTime}ms...");

      await Future.delayed(Duration(milliseconds: waitTime));

      try {
        final response = await err.requestOptions
            .copyWith(extra: options.extra)
            .retryWith(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.badResponse;
  }

  int _calculateBackoff(int attempt) {
    final rand = Random();
    return baseDelay * pow(2, attempt).toInt() + rand.nextInt(jitter);
  }
}

extension on RequestOptions {
  Future<Response<dynamic>> retryWith(RequestOptions options) async {
    final dio = Dio()
      ..interceptors.addAll([
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: false,
          error: true,
          compact: true,
        ),
      ]);

    dio.options = BaseOptions(
      baseUrl: options.baseUrl,
      headers: options.headers,
      connectTimeout: options.connectTimeout,
      receiveTimeout: options.receiveTimeout,
    );

    return await dio.request(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: Options(
        method: options.method,
        headers: options.headers,
        sendTimeout: options.sendTimeout,
        receiveTimeout: options.receiveTimeout,
        extra: options.extra,
        responseType: options.responseType,
        contentType: options.contentType,
      ),
    );
  }
}
