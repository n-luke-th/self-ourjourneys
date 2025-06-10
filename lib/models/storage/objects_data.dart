/// lib/models/storage/objects_data.dart
import 'dart:convert' show json;

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:ourjourneys/helpers/dependencies_injection.dart' show getIt;
import 'package:ourjourneys/services/auth/acc/auth_wrapper.dart'
    show AuthWrapper;

/// The [ObjectsData] class is used to store the data of an object in the database.
class ObjectsData {
  final String objectKey;
  final String fileName;
  final String contentType;
  final String objectThumbnailKey;
  final String userId;
  final int objectSizeInBytes;
  final Timestamp objectUploadRequestedAt;
  final List<String> tags;
  final List<String> linkedAlbums;
  final List<String> linkedMemories;

  ObjectsData(
      {required this.objectKey,
      required this.fileName,
      required this.contentType,
      required this.objectThumbnailKey,
      required this.userId,
      required this.objectSizeInBytes,
      required this.objectUploadRequestedAt,
      required this.linkedAlbums,
      required this.linkedMemories,
      required this.tags});

  Map<String, dynamic> toMap() {
    return {
      'objectKey': objectKey,
      'fileName': fileName,
      'contentType': contentType,
      'objectThumbnailKey': objectThumbnailKey,
      'userId': userId,
      'objectSizeInBytes': objectSizeInBytes,
      'objectUploadRequestedAt': objectUploadRequestedAt,
      'linkedAlbums': linkedAlbums,
      'linkedMemories': linkedMemories,
      'tags': tags
    };
  }

  factory ObjectsData.fromMap(Map<String, dynamic> map) {
    final AuthWrapper authWrapper = getIt<AuthWrapper>();
    authWrapper.refreshUid();
    return ObjectsData(
      objectKey: map['objectKey'] ?? '',
      fileName: map['fileName'] ?? '',
      contentType: map['contentType'] ?? '',
      objectThumbnailKey: map['objectThumbnailKey'] ?? '',
      userId: authWrapper.uid,
      objectSizeInBytes: map['objectSizeInBytes'] ?? 0,
      objectUploadRequestedAt: map['objectUploadRequestedAt'] as Timestamp,
      linkedAlbums: List<String>.from(map['linkedAlbums'] ?? []),
      linkedMemories: List<String>.from(map['linkedMemories'] ?? []),
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory ObjectsData.fromJson(String source) =>
      ObjectsData.fromMap(json.decode(source));
}

/// The type of the object.
enum MediaObjectType {
  image("image"),
  video("video"),
  audio("audio"),
  document("document"),
  // nullObject("nullObject"),
  unknown("unknown"),
  imageOrVideo("imageOrVideo");

  final String stringValue;

  const MediaObjectType(this.stringValue);
}
