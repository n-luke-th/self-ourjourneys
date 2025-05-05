/// api service to make interactions with the backend
/// lib/services/api/api_service.dart
///

import 'dart:async';
// import 'dart:math';

import 'package:logger/logger.dart';
import 'package:ourjourneys/helpers/dependencies_injection.dart';
import 'package:ourjourneys/helpers/utils.dart' show Utils;
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

  /// deletes objects from the server, files must be in the same folder to successful delete
  Future<List<DeleteResult>> deleteFilesInTheSameFolder(
      {required List<String> objectKeys, required String folder}) async {
    final dio = await _dioHandler.getClient(baseUrl: baseUrl);

    final List<String> reformatedObjectKeys = List.from(objectKeys.map((k) =>
        Utils.reformatObjectKey(k,
            forFirestore:
                false))); // ensure the object keys are in the correct format for the server
    final List<String> fileNames =
        reformatedObjectKeys.map((e) => e.split('/').last).toList();

    final response = await dio.delete('/delete-objects/by-names',
        data: {"fileNames": fileNames, "folder": folder});

    if (response.statusCode == 200) {
      final deleted = (response.data['deleted'] as List)
          .map((e) => DeleteResult.fromJson(e))
          .toList();
      _logger.i('Deleted ${deleted.length} files from server');
      return deleted;
    } else {
      _logger.e('Delete failed: ${response.statusCode} ${response.data}');
      throw Exception('Delete failed: ${response.data}');
    }
  }

  /// deletes objects from the server by object keys
  Future<List<DeleteResult>> deleteFilesByObjectKeys(
      {required List<String> objectKeys}) async {
    final dio = await _dioHandler.getClient(baseUrl: baseUrl);

    final List<String> reformatedObjectKeys = List.from(objectKeys.map((k) =>
        Utils.reformatObjectKey(k,
            forFirestore:
                false))); // ensure the object keys are in the correct format for the server

    final response = await dio.delete(
      '/delete-objects/by-keys',
      data: {'objectKeys': reformatedObjectKeys},
    );

    if (response.statusCode == 200) {
      final deleted = (response.data['deleted'] as List)
          .map((e) => DeleteResult.fromJson(e))
          .toList();
      _logger.i('Deleted ${deleted.length} files from server');
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
