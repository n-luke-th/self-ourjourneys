/// lib/services/cloud/cloud_file_service.dart

import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:ourjourneys/helpers/dependencies_injection.dart';
import 'package:ourjourneys/services/api/api_service.dart';
import 'package:logger/logger.dart';
import 'package:ourjourneys/services/network/dio_handler.dart';
import 'package:ourjourneys/shared/services/network_const.dart'
    show NetworkConsts;

class CloudFileService {
  final ApiService _apiService = getIt<ApiService>();
  final Logger _logger = getIt<Logger>();
  final DioHandler _dioHandler = getIt<DioHandler>();

  Future<String?> uploadFile({
    required Uint8List fileBytes,
    required String fileName,
    required String folderPath,
    Null Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      // Request signed URL from backend
      final uploadUrls =
          await _apiService.getUploadUrls(folderPath, [fileName]);
      if (uploadUrls.isEmpty) {
        _logger.w("No upload URL received for $fileName");
        return null;
      }
      final uploadTarget = uploadUrls.first;
      final contentType =
          lookupMimeType(fileName) ?? 'application/octet-stream';

      final Dio dio = await _dioHandler.getClient(
          withAuth: false, baseUrl: NetworkConsts.apiBaseUrl);

      final response = await dio.put(
        uploadTarget.url,
        data: fileBytes,
        onSendProgress: onSendProgress,
        options: Options(
          headers: {
            NetworkConsts.headerContentType: contentType,
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _logger.i("Successfully uploaded $fileName to ${uploadTarget.url}");
        return uploadTarget.url;
      } else {
        _logger.e(
            "Upload failed: ${response.statusCode} ${response.statusMessage}");
        return null;
      }
    } on DioException catch (e) {
      _logger.d('DioError response: ${e.response}');
      _logger.d('DioError request: ${e.requestOptions.toString()}');
    } catch (e, st) {
      _logger.e('Upload failed', error: e, stackTrace: st);

      _logger.e("Exception uploading file '$fileName': ${e.toString()}",
          error: e, stackTrace: st);
      return null;
    }
    return null;
  }

  Future<List<String>> uploadMultipleFiles({
    required List<Uint8List> fileBytesList,
    required List<String> fileNames,
    required String folderPath,
    Null Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final signedUrls = await _apiService.getUploadUrls(folderPath, fileNames);

      if (signedUrls.length != fileBytesList.length) {
        throw Exception("Mismatch in file count vs signed URL count");
      }

      final uploadedUrls = <String>[];
      final dio = await _dioHandler.getClient(
          withAuth: false, baseUrl: NetworkConsts.apiBaseUrl);
      for (int i = 0; i < fileBytesList.length; i++) {
        final result = signedUrls[i];
        final response = await dio.put(
          result.url,
          data: fileBytesList[i],
          onSendProgress: onSendProgress,
          options: Options(
            headers: {
              NetworkConsts.headerContentType:
                  lookupMimeType(result.fileName) ?? 'application/octet-stream',
            },
          ),
        );

        if (response.statusCode == 200 || response.statusCode == 204) {
          uploadedUrls.add(result.url);
        } else {
          _logger.w("Failed to upload ${fileNames[i]}: ${response.statusCode}");
        }
      }
      return uploadedUrls;
    } catch (e, st) {
      _logger.e("Exception uploading multiple files", error: e, stackTrace: st);
      return [];
    }
  }
}
