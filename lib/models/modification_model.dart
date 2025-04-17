/// lib/models/modification_model.dart

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class ModificationData {
  final String createdByUserId;
  final Timestamp createdAt;
  final String lastModifiedByUserId;
  final Timestamp lastModifiedAt;

  ModificationData(
      {required this.createdByUserId,
      required this.createdAt,
      required this.lastModifiedByUserId,
      required this.lastModifiedAt});

  Map<String, dynamic> toMap() {
    return {
      'createdByUserId': createdByUserId,
      'createdAt': createdAt.toString(),
      'lastModifiedByUserId': lastModifiedByUserId,
      'lastModifiedAt': lastModifiedAt.toString(),
    };
  }

  factory ModificationData.fromMap(Map<String, dynamic> map) {
    return ModificationData(
      createdByUserId: map['createdByUserId'] ?? '',
      createdAt: map['createdAt'],
      lastModifiedByUserId: map['lastModifiedByUserId'],
      lastModifiedAt: map['lastModifiedAt'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ModificationData.fromJson(String source) =>
      ModificationData.fromMap(json.decode(source));
}
