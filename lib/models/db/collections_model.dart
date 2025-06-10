/// lib/models/db/collections_model.dart
///

import 'dart:convert' show json;

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

/// collection feature data model
class CollectionsModel {
  final String id;
  final String collectionName;
  final List<String> externalLinks;
  final String collectionBody;
  final Timestamp lastUpdatedAt;

  CollectionsModel(
      {required this.id,
      required this.collectionName,
      required this.externalLinks,
      required this.collectionBody,
      required this.lastUpdatedAt});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'collectionName': collectionName,
      'externalLinks': externalLinks,
      'collectionBody': collectionBody,
      'lastUpdatedAt': lastUpdatedAt
    };
  }

  factory CollectionsModel.fromMap(
      {required Map<String, dynamic> map, required String docId}) {
    return CollectionsModel(
        id: docId,
        collectionName: map['collectionName'] ?? "",
        externalLinks: List<String>.from(map['externalLinks'] ?? []),
        collectionBody: map['collectionBody'] ?? "",
        lastUpdatedAt: map['lastUpdatedAt'] as Timestamp);
  }

  String toJson() => json.encode(toMap());

  factory CollectionsModel.fromJson(
          {required String source, required String docId}) =>
      CollectionsModel.fromMap(map: json.decode(source), docId: docId);
}
