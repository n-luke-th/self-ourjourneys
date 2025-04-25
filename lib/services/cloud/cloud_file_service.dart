/// lib/services/cloud/cloud_file_service.dart

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';

import 'package:ourjourneys/helpers/dependencies_injection.dart';
import 'package:ourjourneys/models/storage/objects_data.dart';
import 'package:ourjourneys/services/api/api_service.dart';
import 'package:ourjourneys/services/auth/acc/auth_wrapper.dart';
import 'package:ourjourneys/services/db/firestore_wrapper.dart';
import 'package:ourjourneys/services/network/dio_handler.dart';
import 'package:ourjourneys/shared/services/firestore_commons.dart';
import 'package:ourjourneys/shared/services/network_const.dart'
    show NetworkConsts;

class CloudFileService {
  final FirestoreWrapper _firestoreWrapper = getIt<FirestoreWrapper>();
  final AuthWrapper _authWrapper = getIt<AuthWrapper>();
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
      final isAlreadyExisting = await _firestoreWrapper.getDocumentById(
          FirestoreCollections.objectsData, uploadUrls[0].key);
      if (isAlreadyExisting.exists) {
        _logger.w("File '$fileName' already exists");
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
        return uploadTarget.key;
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

  Future<(List<String> successKeys, Set<String> failedFileNames)>
      uploadMultipleFiles({
    required BuildContext context,
    required List<Uint8List> fileBytesList,
    required List<String> fileNames,
    required String folderPath,
    required void Function(int fileIndex) onFileIndexChanged,
    Null Function(int sent, int total)? onSendProgress,
  }) async {
    final successKeys = <String>[];
    final failedFileNames = <String>{};
    final dio = await _dioHandler.getClient(
        withAuth: false, baseUrl: NetworkConsts.apiBaseUrl);

    try {
      final requestedTime = Timestamp.now();
      final fileResults =
          await _apiService.getUploadUrls(folderPath, fileNames);

      if (fileResults.length != fileBytesList.length) {
        throw Exception("Mismatch in file count vs signed URL count");
      }

      final aggregateTotal =
          fileBytesList.fold<int>(0, (sum, file) => sum + file.length);

      for (int i = 0; i < fileBytesList.length; i++) {
        final result = fileResults[i];
        onFileIndexChanged(i);
        final isAlreadyExisting = await _firestoreWrapper.getDocumentById(
            FirestoreCollections.objectsData, result.key);
        if (isAlreadyExisting.exists) {
          _logger.w("File '${fileNames[i]}' already exists, skipping");
          failedFileNames.add(fileNames[i]);
          continue;
        }
        try {
          final response = await dio.put(
            result.url,
            data: fileBytesList[i],
            onSendProgress: (sent, total) {
              final previousTotalSent = fileBytesList
                  .sublist(0, i)
                  .fold<int>(0, (sum, file) => sum + file.length);

              final aggregateSent = previousTotalSent + sent;
              onSendProgress?.call(aggregateSent, aggregateTotal);
            },
            // onSendProgress: onSendProgress,
            options: Options(
              headers: {
                NetworkConsts.headerContentType:
                    lookupMimeType(result.fileName) ??
                        'application/octet-stream',
              },
            ),
          );

          if (response.statusCode == 200 || response.statusCode == 204) {
            successKeys.add(result.key);
            await _saveToFirestore(
              // ignore: use_build_context_synchronously
              context,
              objectKey: result.key,
              fileName: result.fileName,
              contentType:
                  lookupMimeType(result.fileName) ?? 'application/octet-stream',
              objectUrl: "${NetworkConsts.cdnUrl}/${result.key}",
              objectUploadRequestedAt: requestedTime,
              tags: [],
              linkedAlbums: [],
              linkedMemories: [],
            );
          } else {
            failedFileNames.add(fileNames[i]);
          }
        } catch (e) {
          failedFileNames.add(fileNames[i]);
        }
      }

      return (successKeys, failedFileNames);
    } catch (e, st) {
      _logger.e("Exception uploading multiple files", error: e, stackTrace: st);
      return (successKeys, failedFileNames);
    }
  }

  Future<void> _saveToFirestore(
    BuildContext context, {
    required String objectKey,
    required String fileName,
    required String contentType,
    required String objectUrl,
    required Timestamp objectUploadRequestedAt,
    List<String> tags = const [],
    List<String> linkedAlbums = const [],
    List<String> linkedMemories = const [],
  }) async {
    _authWrapper.refreshAttributes();
    final objectData = ObjectsData(
      objectKey: objectKey,
      fileName: fileName,
      contentType: contentType,
      objectUrl: objectUrl,
      userId: _authWrapper.uid,
      objectUploadRequestedAt: objectUploadRequestedAt,
      tags: tags,
      linkedAlbums: linkedAlbums,
      linkedMemories: linkedMemories,
    );

    await _firestoreWrapper.handleCreateDocument(
        context, FirestoreCollections.objectsData, objectData.toMap(),
        useCustomDocID: true,
        customDocID: objectKey,
        suppressNotification: true);
  }
}
