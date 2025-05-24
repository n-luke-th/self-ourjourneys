/// lib/services/cloud/cloud_file_service.dart
///
/// cloud file service for uploading files to cloud storage

// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';

import 'package:ourjourneys/helpers/dependencies_injection.dart';
import 'package:ourjourneys/helpers/utils.dart';
import 'package:ourjourneys/models/storage/file_model.dart' show DeleteResult;
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

  Future<String?> uploadFile(
    BuildContext context, {
    required Uint8List fileBytes,
    required String fileName,
    required String folderPath,
    Null Function(int sent, int total)? onSendProgress,
    List<String> tags = const [],
    List<String> linkedAlbums = const [],
    List<String> linkedMemories = const [],
  }) async {
    try {
      final requestedTime = Timestamp.now();
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
          withAuth: false, baseUrl: uploadTarget.url);

      final response = await dio.putUri(
        Uri.parse(uploadTarget.url),
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
        await _saveToFirestore(
          context,
          objectKey: uploadTarget.key,
          fileName: uploadTarget.fileName,
          objectSizeInBytes: fileBytes.length,
          contentType: lookupMimeType(uploadTarget.fileName) ??
              'application/octet-stream',
          objectThumbnailKey:
              Utils.getThumbnailKeyFromObjectKey(uploadTarget.key),
          objectUploadRequestedAt: requestedTime,
          tags: tags,
          linkedAlbums: linkedAlbums,
          linkedMemories: linkedMemories,
        );
        return uploadTarget.key;
      } else {
        _logger.e(
            "Upload failed: ${response.statusCode} ${response.statusMessage}");
        return null;
      }
    } on DioException catch (e) {
      _logger.d('DioError response: ${e.response}');
      _logger.d('DioError request: ${e.requestOptions.toString()}');
      rethrow;
    } catch (e, st) {
      _logger.e('Upload failed', error: e, stackTrace: st);

      _logger.e("Exception uploading file '$fileName': ${e.toString()}",
          error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<(List<String> successKeys, Set<String> failedFileNames)>
      uploadMultipleFiles({
    required BuildContext context,
    required List<Uint8List> fileBytesList,
    required List<String> fileNames,
    required String folderPath,
    required void Function(int fileIndex) onFileIndexChanged,
    Null Function(int sent, int total)? onSendProgress,
    List<String> tags = const [],
    List<String> linkedAlbums = const [],
    List<String> linkedMemories = const [],
  }) async {
    final successKeys = <String>[];
    final failedFileNames = <String>{};

    try {
      final requestedTime = Timestamp.now();
      final fileResults =
          await _apiService.getUploadUrls(folderPath, fileNames);

      if (fileBytesList.length != fileResults.length) {
        _logger.d("signed urls: [${fileResults.map((e) => e.url).toList()}]");
        _logger.d("file amount: ${fileBytesList.length}");
        _logger.w(
            "Mismatch in file count vs signed URL count: ${fileBytesList.length} vs ${fileResults.length}");
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
          final dio =
              await _dioHandler.getClient(withAuth: false, baseUrl: result.url);
          final response = await dio.putUri(
            Uri.parse(result.url),
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
              context,
              objectKey: result.key,
              fileName: result.fileName,
              objectSizeInBytes: fileBytesList[i].length,
              contentType:
                  lookupMimeType(result.fileName) ?? 'application/octet-stream',
              objectThumbnailKey:
                  Utils.getThumbnailKeyFromObjectKey(result.key),
              objectUploadRequestedAt: requestedTime,
              tags: tags,
              linkedAlbums: linkedAlbums,
              linkedMemories: linkedMemories,
            );
          } else {
            failedFileNames.add(fileNames[i]);
            continue;
          }
        } catch (e) {
          failedFileNames.add(fileNames[i]);
          continue;
        }
      }

      return (successKeys, failedFileNames);
    } catch (e, st) {
      _logger.e("Exception uploading multiple files", error: e, stackTrace: st);
      return (successKeys, failedFileNames);
    }
  }

  /// deletes objects from the server, files must be in the same folder to successful delete
  Future<List<DeleteResult>> deleteObjectsSameFolder(BuildContext context,
      {required List<String> objectKeys, required String folder}) async {
    try {
      _logger.d("Deleting objects from server by names");
      final response = await _apiService.deleteFilesInTheSameFolder(
          objectKeys: objectKeys, folder: folder);
      final List<String> reformatedObjectKeys =
          List.from(objectKeys.map((k) => Utils.reformatObjectKey(k)));
      _logger.d("Deleting 'objectsData' documents from Firestore");
      if (response.isNotEmpty && (response.length == objectKeys.length)) {
        await _firestoreWrapper.handleBatchDelete(context,
            collection: FirestoreCollections.objectsData,
            documentIds: reformatedObjectKeys,
            suppressNotification: true);
      } else if (response.isNotEmpty && (response.length < objectKeys.length)) {
        for (int i = 0; i < response.length; i++) {
          await _firestoreWrapper.handleDeleteDocument(
              context,
              FirestoreCollections.objectsData,
              Utils.reformatObjectKey(response[i].key),
              suppressNotification: true);
        }
      }
      _logger.i("Documents deleted: '${response.map((e) => e.key).toList()}'");
      return response;
    } on DioException catch (e) {
      _logger.d('DioError response: ${e.response}');
      _logger.d('DioError request: ${e.requestOptions.toString()}');
      rethrow;
    } catch (e, st) {
      _logger.e('Delete failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// deletes objects from the server by object keys
  Future<List<DeleteResult>> deleteObjectsByKeys(BuildContext context,
      {required List<String> objectKeys}) async {
    try {
      _logger.d("Deleting objects from server by keys");
      final response =
          await _apiService.deleteFilesByObjectKeys(objectKeys: objectKeys);
      final List<String> reformatedObjectKeys =
          List.from(objectKeys.map((k) => Utils.reformatObjectKey(k)));
      _logger.d("Deleting 'objectsData' documents from Firestore");
      if (response.isNotEmpty && (response.length == objectKeys.length)) {
        await _firestoreWrapper.handleBatchDelete(context,
            collection: FirestoreCollections.objectsData,
            documentIds: reformatedObjectKeys,
            suppressNotification: true);
      } else if (response.isNotEmpty && (response.length < objectKeys.length)) {
        for (int i = 0; i < response.length; i++) {
          await _firestoreWrapper.handleDeleteDocument(
              context,
              FirestoreCollections.objectsData,
              Utils.reformatObjectKey(response[i].key),
              suppressNotification: true);
        }
      }
      _logger.i("Documents deleted: '${response.map((e) => e.key).toList()}'");
      return response;
    } on DioException catch (e) {
      _logger.d('DioError response: ${e.response}');
      _logger.d('DioError request: ${e.requestOptions.toString()}');
      rethrow;
    } catch (e, st) {
      _logger.e('Delete failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> _saveToFirestore(
    BuildContext context, {
    required String objectKey,
    required String fileName,
    required String contentType,
    required String objectThumbnailKey,
    required int objectSizeInBytes,
    required Timestamp objectUploadRequestedAt,
    List<String> tags = const [],
    List<String> linkedAlbums = const [],
    List<String> linkedMemories = const [],
  }) async {
    _authWrapper.refreshUid();
    final objectData = ObjectsData(
      objectKey: objectKey,
      fileName: fileName,
      contentType: contentType,
      objectThumbnailKey: objectThumbnailKey,
      userId: _authWrapper.uid,
      objectSizeInBytes: objectSizeInBytes,
      objectUploadRequestedAt: objectUploadRequestedAt,
      tags: tags,
      linkedAlbums: linkedAlbums,
      linkedMemories: linkedMemories,
    );

    await _firestoreWrapper.handleCreateDocument(context,
        collectionName: FirestoreCollections.objectsData,
        data: objectData.toMap(),
        useCustomDocID: true,
        customDocID: Utils.reformatObjectKey(objectKey),
        suppressNotification: true);
  }
}
