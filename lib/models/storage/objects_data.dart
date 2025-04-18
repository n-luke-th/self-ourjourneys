import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:ourjourneys/helpers/dependencies_injection.dart';
import 'package:ourjourneys/services/auth/acc/auth_wrapper.dart';

class ObjectsData {
  final String objectKey;
  final String fileName;
  final String contentType;
  final String objectUrl;
  final String userId;
  final Timestamp objectUploadRequestedAt;
  final List<String> tags;
  final List<String> linkedAlbums;
  final List<String> linkedMemories;

  ObjectsData(
      {required this.objectKey,
      required this.fileName,
      required this.contentType,
      required this.objectUrl,
      required this.userId,
      required this.objectUploadRequestedAt,
      required this.linkedAlbums,
      required this.linkedMemories,
      required this.tags});

  Map<String, dynamic> toMap() {
    return {
      'objectKey': objectKey,
      'fileName': fileName,
      'contentType': contentType,
      'objectUrl': objectUrl,
      'userId': userId,
      'objectUploadRequestedAt': objectUploadRequestedAt,
      'linkedAlbums': linkedAlbums,
      'linkedMemories': linkedMemories,
      'tags': tags
    };
  }

  factory ObjectsData.fromMap(Map<String, dynamic> map) {
    final AuthWrapper authWrapper = getIt<AuthWrapper>();
    return ObjectsData(
        objectKey: map['objectKey'] ?? '',
        fileName: map['fileName'] ?? '',
        contentType: map['contentType'] ?? '',
        objectUrl: map['objectUrl'] ?? '',
        userId: authWrapper.uid,
        objectUploadRequestedAt: map['objectUploadRequestedAt'],
        linkedAlbums: map["linkedAlbums"] ?? [],
        linkedMemories: map['linkedMemories'] ?? [],
        tags: map['tags'] ?? []);
  }

  String toJson() => json.encode(toMap());

  factory ObjectsData.fromJson(String source) =>
      ObjectsData.fromMap(json.decode(source));
}
