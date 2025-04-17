/// lib/models/db/memories_model.dart
///
/// memories model
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' show GeoPoint;
import 'package:ourjourneys/models/modification_model.dart';

class MemoriesModel {
  final String id;
  final String memoryName;
  final String? memoryDes;
  final GeoPoint? geoPoint;
  final List<String> linkedObjects;
  final ModificationData modificationData;

  MemoriesModel(
      {required this.id,
      required this.memoryName,
      required this.memoryDes,
      required this.geoPoint,
      required this.linkedObjects,
      required this.modificationData});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memoryName': memoryName,
      'memoryDes': memoryDes,
    };
  }

  factory MemoriesModel.fromMap(
      {required Map<String, dynamic> map, required String docId}) {
    return MemoriesModel(
        id: docId,
        memoryName: map['memoryName'] ?? '',
        memoryDes: map['memoryDes'],
        geoPoint: map['geoPoint'],
        linkedObjects: map['linkedObjects'] ?? [],
        modificationData: ModificationData.fromMap(map['modificationData']));
  }

  String toJson() => json.encode(toMap());

  factory MemoriesModel.fromJson(
          {required String source, required String docId}) =>
      MemoriesModel.fromMap(map: json.decode(source), docId: docId);
}
