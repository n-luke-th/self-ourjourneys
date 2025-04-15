/// api service to make interactions with the backend
/// lib/services/api/api_service.dart
///

import 'dart:async';
// import 'dart:math';

import 'package:logger/logger.dart';
import 'package:ourjourneys/helpers/dependencies_injection.dart';
import 'package:ourjourneys/models/storage/file_model.dart';
import 'package:ourjourneys/services/network/dio_handler.dart';
import 'package:ourjourneys/shared/services/network_const.dart';

class ApiService {
  final String baseUrl = NetworkConsts.apiBaseUrl;
  final DioHandler _dioHandler = getIt<DioHandler>();
  final Logger _logger = getIt<Logger>();

  ApiService();

  Future<List<FileResult>> getUploadUrls(
      String folder, List<String> fileNames) async {
    return _postFileRequest(
      endpoint: '/gen-upload-urls',
      body: {
        'folder': folder,
        'fileNames': fileNames,
      },
    );
  }

  Future<List<DeleteResult>> deleteFiles(
      {required List<String> objectKeys}) async {
    final dio = await _dioHandler.getClient(baseUrl: baseUrl);
    final response = await dio.post(
      '/delete-objects',
      data: {'objectKeys': objectKeys},
    );

    if (response.statusCode == 200) {
      final deleted = (response.data['deleted'] as List)
          .map((e) => DeleteResult.fromJson(e))
          .toList();
      _logger.i('Deleted ${deleted.length} files');
      return deleted;
    } else {
      _logger.e('Delete failed: ${response.statusCode} ${response.data}');
      throw Exception('Delete failed: ${response.data}');
    }
  }

  Future<List<FileResult>> _postFileRequest({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    final dio = await _dioHandler.getClient(baseUrl: baseUrl, withAuth: true);
    final response = await dio.post(endpoint, data: body);

    if (response.statusCode == 200) {
      final results = response.data['results'];
      final files = (results is List)
          ? results.map((e) => FileResult.fromJson(e)).toList()
          : [FileResult.fromJson(results)];

      _logger.i('Fetched ${files.length} URLs from $endpoint');
      _logger.d("response: ${response.data}");
      return files;
    } else {
      _logger.e(
          'Request to $endpoint failed: ${response.statusCode} ${response.data}');
      throw Exception('Request to $endpoint failed: ${response.data}');
    }
  }
}

// class ApiService {
//   final String baseUrl = ApiConsts.apiBaseUrl;
//   final int maxRetries;
//   final DioHandler _dioHandler = getIt<DioHandler>();
//   final Logger _logger = getIt<Logger>();

//   ApiService({this.maxRetries = 2});

//   Future<List<FileResult>> getUploadUrls(
//       String folder, List<String> fileNames) async {
//     return _postFileRequest(
//       endpoint: '/c/obtain-signed-urls',
//       body: {'folder': folder, 'fileNames': fileNames},
//     );
//   }

//   Future<List<FileResult>> getDownloadUrls(
//       String folder, List<String> fileNames) async {
//     return _postFileRequest(
//       endpoint: '/r/obtain-signed-urls',
//       body: {'folder': folder, 'fileNames': fileNames},
//     );
//   }

//   Future<List<DeleteResult>> deleteFiles(
//       {required List<String> fileNames, required String folder}) async {
//     final dio = await _dioHandler.getClient();
//     final response = await dio.post(
//       '/d/delete-objects',
//       data: {'fileNames': fileNames, 'folder': folder},
//     );

//     if (response.statusCode == 200) {
//       final deleted = (response.data['deleted'] as List)
//           .map((e) => DeleteResult.fromJson(e))
//           .toList();
//       _logger.i('Deleted ${deleted.length} files');
//       return deleted;
//     } else {
//       _logger.e('Delete failed: ${response.statusCode} ${response.data}');
//       throw Exception('Delete failed: ${response.data}');
//     }
//   }

//   Future<List<FileResult>> _postFileRequest({
//     required String endpoint,
//     required Map<String, dynamic> body,
//   }) async {
//     final dio = await _dioHandler.getClient();
//     final response = await dio.post(endpoint, data: body);

//     if (response.statusCode == 200) {
//       final results = response.data['results'];
//       final files = (results is List)
//           ? results.map((e) => FileResult.fromJson(e)).toList()
//           : [FileResult.fromJson(results)];

//       _logger.i('Fetched ${files.length} URLs from $endpoint');
//       _logger.d("response: ${response.data}");
//       return files;
//     } else {
//       _logger.e(
//           'Request to $endpoint failed: ${response.statusCode} ${response.data}');
//       throw Exception('Request to $endpoint failed: ${response.data}');
//     }
//   }

//   // Future<T> _retry<T>(Future<T> Function() task) async {
//   //   int attempt = 0;
//   //   while (true) {
//   //     try {
//   //       return await task();
//   //     } catch (e, stack) {
//   //       attempt++;
//   //       if (attempt > maxRetries) {
//   //         _logger.e('Max retries exceeded. Throwing error.',
//   //             error: e, stackTrace: stack);
//   //         rethrow;
//   //       }
//   //       final waitTime = _calculateBackoff(attempt);
//   //       _logger.w('Attempt $attempt failed. Retrying in ${waitTime}ms...',
//   //           error: e);
//   //       await Future.delayed(Duration(milliseconds: waitTime));
//   //     }
//   //   }
//   // }

//   // int _calculateBackoff(int attempt) {
//   //   final baseDelay = 500; // milliseconds
//   //   final maxJitter = 300;
//   //   final random = Random();
//   //   return baseDelay * pow(2, attempt).toInt() + random.nextInt(maxJitter);
//   // }
// }
