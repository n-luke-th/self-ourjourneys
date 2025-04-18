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
}
