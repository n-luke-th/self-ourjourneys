/// lib/helpers/utils.dart
/// Utils class

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:file_picker/file_picker.dart' show FileType, FilePickerResult;
import 'package:get_time_ago/get_time_ago.dart' show GetTimeAgo;
import 'package:intl/intl.dart' show DateFormat;
import 'package:mime/mime.dart' show lookupMimeType;
import 'package:ourjourneys/helpers/get_platform_service.dart';
import 'package:ourjourneys/models/storage/selected_file.dart'
    show SelectedFile;
import 'package:path/path.dart' as path show extension;

import 'package:ourjourneys/services/configs/utils/files_picker_utils.dart'
    show FilesPickerUtils;
import 'package:ourjourneys/shared/common/file_picker_enum.dart'
    show AllowedExtensions;

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

  /// Returns a reformatted object key
  /// replaces either a backslash or a forward slash with the other
  static String reformatObjectKey(String objectKey,
      {bool forFirestore = true}) {
    // final regex = r'\\|/'; // Matches either a backslash or a forward slash
    if (forFirestore) {
      return objectKey.replaceAll(RegExp(r'/'), r'\'); // Replace '/' with '\'
    } else {
      return objectKey.replaceAll(RegExp(r'\\'), r'/'); // Replace '\' with '/'
    }
  }

  /// Returns a detected file type from a file path.
  ///
  /// Returns `others` if the file type is not recognized.
  /// Returns `image` if the file type is an image.
  /// Returns `video` if the file type is a video.
  /// Returns `document` if the file type is a document.
  static String detectFileTypeFromFilepath(String filePath) {
    final filename = filePath.split('/').last;
    final mimeType = lookupMimeType(filename);

    if (mimeType == null) {
      return 'others';
    }

    if (mimeType.startsWith('image/')) {
      return 'image';
    } else if (mimeType.startsWith('video/')) {
      return 'video';
    } else if (mimeType.startsWith('application/') ||
        mimeType.startsWith('text/')) {
      final extension = path.extension(filename).toLowerCase();
      if ([
        '.doc',
        '.docx',
        '.xls',
        '.xlsx',
        '.ppt',
        '.pptx',
        '.csv',
        ...AllowedExtensions.documentExtensions
      ].contains(extension)) {
        return 'document';
      } else {
        return 'others';
      }
    } else {
      return 'others';
    }
  }

  /// Returns [String] of the folder path from the full valid object key.
  /// Otherwise returns [Null].
  ///
  /// Example: 'uploads/20210507T063025Z-fsjkskjs3/linkedinProfile.png'
  ///
  /// Would returns: "uploads/20210507T063025Z-fsjkskjs3"
  static String? getFolderPathFromObjectKey(String objectKey) {
    int lastSeparator = objectKey.lastIndexOf('/');

    if (lastSeparator != -1) {
      String pathWithoutFilename = objectKey.substring(0, lastSeparator);
      return pathWithoutFilename;
    } else {
      return null;
    }
  }

  static Future<void> pickLocalFiles(
      {void Function()? onCompleted,
      required void Function(List<SelectedFile>) onFilesSelected}) async {
    FilePickerResult? result;
    if (PlatformDetectionService.isWeb) {
      result = await FilesPickerUtils.pickFiles(
        allowMultiple: true,
        fileType: FileType.custom,
        allowedExtensions: [
          ...AllowedExtensions.imageCompactExtensions,
          ...AllowedExtensions.videoExtensions,
        ],
        withData: true,
      );
    } else {
      result = await FilesPickerUtils.pickFiles(
        allowMultiple: true,
        fileType: FileType.media,
        withData: true,
      );
    }
    if (result == null || result.files.isEmpty) return;

    final picked = result.files
        .where((f) => f.bytes != null)
        .map((f) => SelectedFile(file: f, bytes: f.bytes!))
        .toList();

    onFilesSelected(picked);

    onCompleted?.call();
  }
}
