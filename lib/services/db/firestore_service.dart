/// a noSQL database service: Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ourjourneys/shared/services/firestore_commons.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const int _batchLimit = 500; // Firestore batch limit

  /// Get a single document
  Future<DocumentSnapshot> getDocument(String collection, String docId,
      {Source source = Source.serverAndCache}) async {
    return await _firestore
        .collection(collection)
        .doc(docId)
        .get(GetOptions(source: source));
  }

  /// Get a collection of documents
  Stream<QuerySnapshot<Map<String, dynamic>>> getCollectionAsStream(
      String collection) {
    return _firestore.collection(collection).snapshots();
  }

  /// Add a new document
  Future<DocumentReference> addDocument(
      String collection, Map<String, dynamic> data) async {
    return await _firestore.collection(collection).add(data);
  }

  /// Update a document
  Future<void> updateDocument(
      String collection, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(docId).update(data);
  }

  /// Delete a document
  Future<void> deleteDocument(String collection, String docId) async {
    await _firestore.collection(collection).doc(docId).delete();
  }

  // QUERY OPERATIONS

  Query<Object?> _applyQueryConditions(Query query, List<QueryFilter> filters) {
    for (var filter in filters) {
      query = query.where(
        filter.field,
        isEqualTo:
            filter.condition == QueryCondition.isEqualTo ? filter.value : null,
        isNotEqualTo: filter.condition == QueryCondition.isNotEqualTo
            ? filter.value
            : null,
        isLessThan:
            filter.condition == QueryCondition.isLessThan ? filter.value : null,
        isLessThanOrEqualTo:
            filter.condition == QueryCondition.isLessThanOrEqualTo
                ? filter.value
                : null,
        isGreaterThan: filter.condition == QueryCondition.isGreaterThan
            ? filter.value
            : null,
        isGreaterThanOrEqualTo:
            filter.condition == QueryCondition.isGreaterThanOrEqualTo
                ? filter.value
                : null,
        arrayContains: filter.condition == QueryCondition.arrayContains
            ? filter.value
            : null,
        arrayContainsAny: filter.condition == QueryCondition.arrayContainsAny
            ? filter.value
            : null,
        whereIn:
            filter.condition == QueryCondition.whereIn ? filter.value : null,
        whereNotIn:
            filter.condition == QueryCondition.whereNotIn ? filter.value : null,
        isNull: filter.condition == QueryCondition.isNull ? filter.value : null,
      );
    }
    return query;
  }

  // Perform a query
  Stream<QuerySnapshot> queryCollection(
      String collection, List<QueryFilter> filters,
      {int? limit, String? orderBy, bool descending = false}) {
    Query query = _firestore.collection(collection);

    query = _applyQueryConditions(query, filters);

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots();
  }

  Query queryCollectionAsQuery(String collection, List<QueryFilter> filters,
      {int? limit, String? orderBy, bool descending = false}) {
    Query query = _firestore.collection(collection);

    query = _applyQueryConditions(query, filters);

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query;
  }

  // BATCH OPERATIONS

  /// Creates multiple documents in batches
  /// Returns a BatchResult containing successful operations and any errors
  Future<BatchResult> createMultipleDocuments(
    String collection,
    List<Map<String, dynamic>> documents,
  ) async {
    final results = BatchResult();

    try {
      for (var i = 0; i < documents.length; i += _batchLimit) {
        final batch = _firestore.batch();
        final end = (i + _batchLimit < documents.length)
            ? i + _batchLimit
            : documents.length;
        final chunk = documents.sublist(i, end);

        final chunkRefs = <DocumentReference>[];
        for (var doc in chunk) {
          final docRef = _firestore.collection(collection).doc();
          batch.set(docRef, doc);
          chunkRefs.add(docRef);
        }

        await batch.commit();
        results.successful.addAll(chunkRefs);
      }
    } catch (e) {
      results.error = e;
    }

    return results;
  }

  /// Updates multiple documents in batches
  /// Takes a map of document IDs to their update data
  Future<BatchResult> updateMultipleDocuments(
    String collection,
    Map<String, Map<String, dynamic>> updates,
  ) async {
    final results = BatchResult();
    final entries = updates.entries.toList();

    try {
      for (var i = 0; i < entries.length; i += _batchLimit) {
        final batch = _firestore.batch();
        final end = (i + _batchLimit < entries.length)
            ? i + _batchLimit
            : entries.length;
        final chunk = entries.sublist(i, end);

        final chunkRefs = <DocumentReference>[];
        for (var entry in chunk) {
          final docRef = _firestore.collection(collection).doc(entry.key);
          batch.update(docRef, entry.value);
          chunkRefs.add(docRef);
        }

        await batch.commit();
        results.successful.addAll(chunkRefs);
      }
    } catch (e) {
      results.error = e;
    }

    return results;
  }

  /// Deletes multiple documents in batches
  Future<BatchResult> deleteMultipleDocuments(
    String collection,
    List<String> documentIds,
  ) async {
    final results = BatchResult();

    try {
      for (var i = 0; i < documentIds.length; i += _batchLimit) {
        final batch = _firestore.batch();
        final end = (i + _batchLimit < documentIds.length)
            ? i + _batchLimit
            : documentIds.length;
        final chunk = documentIds.sublist(i, end);

        final chunkRefs = <DocumentReference>[];
        for (var id in chunk) {
          final docRef = _firestore.collection(collection).doc(id);
          batch.delete(docRef);
          chunkRefs.add(docRef);
        }

        await batch.commit();
        results.successful.addAll(chunkRefs);
      }
    } catch (e) {
      results.error = e;
    }

    return results;
  }

  // TRANSACTION OPERATIONS

  // Transaction method for atomic operations
  Future<T> runTransaction<T>(
      Future<T> Function(Transaction transaction) transactionHandler) async {
    return await _firestore.runTransaction(transactionHandler);
  }

  // UTILITY METHODS

  Future<void> clearPersistant() async {
    return await _firestore.clearPersistence();
  }
}

/// Result class for batch operations to track successes and failures
class BatchResult {
  final List<DocumentReference> successful = [];
  Object? error;

  bool get hasError => error != null;
  int get successCount => successful.length;
}
