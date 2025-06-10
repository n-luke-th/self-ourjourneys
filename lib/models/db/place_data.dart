/// lib/models/db/place_data.dart
///

import 'dart:convert' show json;

import 'package:cloud_firestore/cloud_firestore.dart' show GeoPoint;

/// the place data used in the [MemoriesModel]
class PlaceData {
  final GeoPoint? geoPoint;
  final String placeName;
  final String placeDes;

  PlaceData({
    this.geoPoint,
    required this.placeName,
    required this.placeDes,
  });

  Map<String, dynamic> toMap() {
    return {
      'geoPoint': geoPoint ?? GeoPoint(0, 0),
      'placeName': placeName,
      'placeDes': placeDes,
    };
  }

  factory PlaceData.fromMap(Map<String, dynamic> map) {
    return PlaceData(
      geoPoint: map['geoPoint'] as GeoPoint? ?? GeoPoint(0, 0),
      placeName: map['placeName'] ?? '',
      placeDes: map['placeDes'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory PlaceData.fromJson(String source) =>
      PlaceData.fromMap(json.decode(source));
}
