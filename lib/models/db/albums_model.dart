import 'dart:convert';

import 'package:ourjourneys/models/modification_model.dart';

class AlbumsModel {
  final String id;
  final String albumName;
  final List<String> linkedObjects;
  final ModificationData modificationData;

  AlbumsModel(
      {required this.id,
      required this.albumName,
      required this.linkedObjects,
      required this.modificationData});

  /// Converts the [AlbumsModel] to a map without the ID.
  Map<String, dynamic> toMap() {
    return {
      'albumName': albumName,
      'linkedObjects': linkedObjects,
      'modificationData': modificationData.toMap(),
    };
  }

  factory AlbumsModel.fromMap(
      {required Map<String, dynamic> map, required String docId}) {
    return AlbumsModel(
      id: docId,
      albumName: map['albumName'] ?? '',
      linkedObjects: List<String>.from(map['linkedObjects']),
      modificationData: ModificationData.fromMap(map['modificationData']),
    );
  }

  String toJson() => json.encode(toMap());

  factory AlbumsModel.fromJson(
          {required String source, required String docId}) =>
      AlbumsModel.fromMap(map: json.decode(source), docId: docId);

  AlbumsModel copyWith(
      {ModificationData? modificationData,
      String? id,
      String? albumName,
      List<String>? linkedObjects}) {
    return AlbumsModel(
      id: id ?? this.id,
      albumName: albumName ?? this.albumName,
      linkedObjects: linkedObjects ?? this.linkedObjects,
      modificationData: modificationData ?? this.modificationData,
    );
  }
}
