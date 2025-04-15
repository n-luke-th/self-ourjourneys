/// the Firestore wrapper functions
/// are the top-level functions that will perform
/// neccessary Firestore actions called when user trigger call to action btn (create btn, delete btn, etc.)

// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:ourjourneys/helpers/dependencies_injection.dart';
import 'package:ourjourneys/services/db/firestore_service.dart';
import 'package:ourjourneys/services/notifications/notification_manager.dart';
import 'package:ourjourneys/services/notifications/notification_service.dart';
import 'package:ourjourneys/shared/services/firestore_commons.dart';
import 'package:provider/provider.dart';

class FirestoreWrapper {
  final FirestoreService _firestoreService = getIt<FirestoreService>();
  final Logger _logger = getIt<Logger>();

  FirestoreWrapper();

  FirestoreService get firestoreService => _firestoreService;

  // QUERY OPERATIONS

  QueryFilter applyQueryFilter(
      String field, dynamic value, QueryCondition condition) {
    return QueryFilter(field, value, condition);
  }

  Stream<DocumentSnapshot<Object?>> queryDocumentAsStream(
      FirestoreCollections collection, String docId) {
    return _firestoreService.getDocument(collection.value, docId).asStream();
  }

  Stream<QuerySnapshot> queryCollectionAsStream(FirestoreCollections collection,
      {List<QueryFilter> filters = const [],
      bool descending = false,
      int? queryLimit,
      String? orderBy}) {
    return _firestoreService.queryCollection("/${collection.value}", filters,
        descending: descending, orderBy: orderBy, limit: queryLimit);
  }

  Future<DocumentSnapshot<Object?>> getDocumentById(
      FirestoreCollections collection, String docId) async {
    return await _firestoreService.getDocument(collection.value, docId);
  }

  // SINGLE DOCUMENT OPERATIONS

  Future<DocumentReference?> handleCreateDocument(BuildContext context,
      FirestoreCollections collectionName, Map<String, dynamic> data,
      {bool suppressNotification = false,
      NotificationData? overrideNotiData,
      NotificationData? overrideErrorNotiData}) async {
    _logger.d("Creating document with data: $data");
    try {
      final doc =
          await _firestoreService.addDocument(collectionName.value, data);
      _showSuccessNotification(
          context, 'Document created', suppressNotification,
          overrideNotiData: overrideNotiData);
      return doc;
    } catch (e) {
      _handleError(context, e, suppressNotification,
          overrideNotiData: overrideErrorNotiData);
      return null;
    }
  }

  Future<void> handleUpdateDocument(
      BuildContext context,
      FirestoreCollections collectionName,
      String docId,
      Map<String, dynamic> data,
      {bool suppressNotification = false,
      NotificationData? overrideNotiData,
      NotificationData? overrideErrorNotiData}) async {
    _logger.d("Updating document '$docId' with data: $data");
    try {
      if (docId != "_") {
        await _firestoreService.updateDocument(
            collectionName.value, docId, data);
        _logger.d('Document "$docId" in "$collectionName" updated!');
        _showSuccessNotification(
            context, 'Document updated', suppressNotification,
            overrideNotiData: overrideNotiData);
      }
    } catch (e) {
      _handleError(context, e, suppressNotification,
          overrideNotiData: overrideErrorNotiData);
    }
  }

  Future<void> handleDeleteDocument(
      BuildContext context, FirestoreCollections collection, String docId,
      {bool suppressNotification = false,
      NotificationData? overrideNotiData,
      NotificationData? overrideErrorNotiData}) async {
    _logger.d("Deleting document '$docId'");
    try {
      if (docId != "_") {
        await _firestoreService.deleteDocument(collection.value, docId);
        _showSuccessNotification(
            context, 'Document deleted', suppressNotification,
            overrideNotiData: overrideNotiData);
      }
    } catch (e) {
      _handleError(context, e, suppressNotification,
          overrideNotiData: overrideErrorNotiData);
    }
  }

  // BATCH OPERATIONS

  Future<void> handleBatchCreate(BuildContext context,
      FirestoreCollections collection, List<Map<String, dynamic>> documents,
      {bool suppressNotification = false,
      NotificationData? overrideNotiData,
      NotificationData? overrideErrorNotiData}) async {
    _logger.d("Creating ${documents.length} documents in ${collection.value}");
    try {
      final result = await _firestoreService.createMultipleDocuments(
        collection.value,
        documents,
      );

      if (result.hasError) {
        throw result.error!;
      }

      _showSuccessNotification(context,
          'Created ${result.successCount} documents', suppressNotification,
          overrideNotiData: overrideNotiData);
    } catch (e) {
      _handleError(context, e, suppressNotification,
          overrideNotiData: overrideErrorNotiData);
    }
  }

  Future<void> handleBatchUpdate(
      BuildContext context,
      FirestoreCollections collection,
      Map<String, Map<String, dynamic>> updates,
      {bool suppressNotification = false,
      NotificationData? overrideNotiData,
      NotificationData? overrideErrorNotiData}) async {
    _logger.d(
        "Updating ${updates.length} documents in '${collection.value}' with Ids: '${updates.keys}'");
    if (updates.isEmpty) return;

    try {
      final result = await _firestoreService.updateMultipleDocuments(
        collection.value,
        updates,
      );

      if (result.hasError) {
        throw result.error!;
      }

      _showSuccessNotification(context,
          'Updated ${result.successCount} documents', suppressNotification,
          overrideNotiData: overrideNotiData);
    } catch (e) {
      _handleError(context, e, suppressNotification,
          overrideNotiData: overrideErrorNotiData);
    }
  }

  Future<void> handleBatchDelete(BuildContext context,
      FirestoreCollections collection, List<String> documentIds,
      {bool suppressNotification = false,
      NotificationData? overrideNotiData,
      NotificationData? overrideErrorNotiData}) async {
    _logger.d(
        "Deleting ${documentIds.length} documents from '${collection.value}' with Ids: '$documentIds'");
    if (documentIds.isEmpty) return;
    try {
      final result = await _firestoreService.deleteMultipleDocuments(
        collection.value,
        documentIds,
      );

      if (result.hasError) {
        throw result.error!;
      }

      _showSuccessNotification(context,
          'Deleted ${result.successCount} documents', suppressNotification,
          overrideNotiData: overrideNotiData);
    } catch (e) {
      _handleError(context, e, suppressNotification,
          overrideNotiData: overrideErrorNotiData);
    }
  }

  // HELPER METHODS

  void _showSuccessNotification(
      BuildContext context, String message, bool suppressNotification,
      {NotificationData? overrideNotiData}) {
    if (!suppressNotification) {
      context.read<NotificationManager>().showNotification(
            context,
            overrideNotiData ??
                NotificationData(
                  title: 'Success',
                  message: message,
                  type: CustomNotificationType.success,
                ),
          );
    }
  }

  void _handleError(
      BuildContext context, dynamic error, bool suppressNotification,
      {NotificationData? overrideNotiData}) {
    final errorMessage = error.toString();
    _logger.e(errorMessage, error: error, stackTrace: StackTrace.current);
    if (!suppressNotification) {
      context.read<NotificationManager>().showNotification(
            context,
            overrideNotiData ??
                NotificationData(
                  title: 'Failed',
                  message: errorMessage,
                  type: CustomNotificationType.error,
                ),
          );
    }
  }
}
