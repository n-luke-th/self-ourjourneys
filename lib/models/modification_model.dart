/// lib/models/modification_model.dart

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:ourjourneys/helpers/utils.dart' show DateTimeUtils;

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

  ModificationData copyWith({
    String? createdByUserId,
    Timestamp? createdAt,
    String? lastModifiedByUserId,
    Timestamp? lastModifiedAt,
  }) {
    return ModificationData(
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedByUserId: lastModifiedByUserId ?? this.lastModifiedByUserId,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'createdByUserId': createdByUserId,
      'createdAt': createdAt,
      'lastModifiedByUserId': lastModifiedByUserId,
      'lastModifiedAt': lastModifiedAt,
    };
  }

  factory ModificationData.fromMap(Map<String, dynamic> map) {
    return ModificationData(
      createdByUserId: map['createdByUserId'] ?? '',
      createdAt: map['createdAt'] as Timestamp,
      lastModifiedByUserId: map['lastModifiedByUserId'],
      lastModifiedAt: map['lastModifiedAt'] as Timestamp,
    );
  }

  String toJson() => json.encode(toMap());

  factory ModificationData.fromJson(String source) =>
      ModificationData.fromMap(json.decode(source));

  /// Returns a modification data string from a given modification data object.
  ///
  /// Returns `(createdString, modifiedString)`
  ///
  /// Example:
  /// - if [combinedIfSame] is `false`: ('Created by You on 2022.01.01 @12:00',
  /// 'Last modified by Your lover on 2022.01.01 @12:00')
  /// - if [combinedIfSame] is `true`: ('Created and last modified by You on 2022.01.01 @12:00', '')
  ///
  static (String createdString, String modifiedString)
      getModificationDataString(
          {required ModificationData modData,
          required String uid,
          bool combinedIfSame = false}) {
    final String timePattern = "y.MM.d @H:mm";
    if (combinedIfSame &&
        (modData.createdByUserId == modData.lastModifiedByUserId) &&
        (modData.createdAt == modData.lastModifiedAt)) {
      // if created and last modified by the same user as well as the created time and last modified time is the same
      final String string =
          "Created and last modified by ${modData.createdByUserId == uid ? "You" : "Your lover"} on ${DateTimeUtils.getReadableDateFromTimestamp(timestamp: modData.createdAt, pattern: timePattern)}";
      return (string, "");
    } else if (combinedIfSame &&
        (modData.createdByUserId == modData.lastModifiedByUserId) &&
        (modData.createdAt != modData.lastModifiedAt)) {
      // if created and last modified by the same user but the created time and last modified time is different
      return (
        "${modData.createdByUserId == uid ? "You" : "Your lover"} have created on ${DateTimeUtils.getReadableDateFromTimestamp(timestamp: modData.createdAt, pattern: timePattern)} and modified on ${DateTimeUtils.getReadableDateFromTimestamp(timestamp: modData.lastModifiedAt, pattern: timePattern)}",
        ""
      );
    } else {
      return (
        "Created by ${modData.createdByUserId == uid ? "You" : "Your lover"} on ${DateTimeUtils.getReadableDateFromTimestamp(timestamp: modData.createdAt, pattern: timePattern)}",
        "Last modified by ${modData.lastModifiedByUserId == uid ? "You" : "Your lover"} on ${DateTimeUtils.getReadableDateFromTimestamp(timestamp: modData.lastModifiedAt, pattern: timePattern)}"
      );
    }
  }
}
