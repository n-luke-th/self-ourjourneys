/// lib/models/db/anniversaries_model.dart
///
import 'dart:convert' show json;

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

/// anniversaries feature data model
class AnniversariesModel {
  final String id;
  final String anniversaryName;
  final Timestamp anniversaryDate;

  AnniversariesModel({
    required this.id,
    required this.anniversaryName,
    required this.anniversaryDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'anniversaryName': anniversaryName,
      'anniversaryDate': anniversaryDate,
    };
  }

  factory AnniversariesModel.fromMap(
      {required Map<String, dynamic> map, required String docId}) {
    return AnniversariesModel(
        id: docId,
        anniversaryName: map['anniversaryName'] ?? '',
        anniversaryDate: map['anniversaryDate'] as Timestamp);
  }

  String toJson() => json.encode(toMap());

  factory AnniversariesModel.fromJson(
          {required String source, required String docId}) =>
      AnniversariesModel.fromMap(map: json.decode(source), docId: docId);
}
