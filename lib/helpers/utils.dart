/// lib/helpers/utils.dart
/// Utils class

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:get_time_ago/get_time_ago.dart' show GetTimeAgo;
import 'package:intl/intl.dart' show DateFormat;

class Utils {
  /// Returns a human readable date string from a DateTime object with a given pattern.
  static String getReadableDate(
      {required DateTime dateTime, required String pattern}) {
    return DateFormat(pattern).format(dateTime);
  }

  /// Returns a human readable date string from a Timestamp object with a given pattern.
  static String getReadableDateFromTimestamp(
      {required Timestamp timestamp, required String pattern}) {
    return DateFormat(pattern).format(timestamp.toDate());
  }

  ///  Returns a DateTime object from a Timestamp object.
  static DateTime getDateTimeFromTimestamp(Timestamp timestamp) {
    return timestamp.toDate();
  }

  /// Returns a human readable time ago from a Timestamp object.
  static String getTimeAgoFromTimestamp(Timestamp timestamp) {
    return GetTimeAgo.parse(timestamp.toDate());
  }

  /// Returns a human readable time ago from a DateTime object.
  static String getTimeAgoFromDateTime(DateTime dateTime) {
    return GetTimeAgo.parse(dateTime);
  }

  /// Returns UTC timestamp string in modified ISO 8601 format.
  static String getUtcTimestampString() {
    final timestamp =
        DateFormat("yyyyMMdd'T'HHmmss'Z'").format(DateTime.now().toUtc());
    return timestamp;
  }

  /// Returns a custom document ID with a given type, user ID, and UTC timestamp.
  ///
  /// Example: "type-userId-timestamp"
  static String genCustomDocId({required String type, required String userId}) {
    return '$type-$userId-${getUtcTimestampString()}';
  }

  static String reformatObjectKey(String objectKey,
      {bool forFirestore = true}) {
    // final regex = r'\\|/'; // Matches either a backslash or a forward slash
    if (forFirestore) {
      return objectKey.replaceAll(RegExp(r'/'), r'\'); // Replace '/' with '\'
    } else {
      return objectKey.replaceAll(RegExp(r'\\'), r'/'); // Replace '\' with '/'
    }
  }
}
