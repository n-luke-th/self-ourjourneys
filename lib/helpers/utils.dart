/// lib/helpers/utils.dart
/// utility classes and functions

import 'dart:math' show log, pow;
import 'dart:typed_data' show Uint8List;

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:crypto/crypto.dart' show md5;
import 'package:file_picker/file_picker.dart' show FileType, FilePickerResult;
import 'package:flutter/widgets.dart'
    show
        MediaQuery,
        BuildContext,
        ScrollController,
        WidgetsBinding,
        Curves,
        Curve;
import 'package:get_time_ago/get_time_ago.dart' show GetTimeAgo;
import 'package:image_picker/image_picker.dart'
    show XFile, ImageSource, CameraDevice;
import 'package:intl/intl.dart' show DateFormat;
import 'package:mime/mime.dart' show lookupMimeType;
import 'package:ourjourneys/errors/platform_exception/custom_platform_exception.dart';
import 'package:ourjourneys/helpers/get_platform_service.dart';
import 'package:ourjourneys/models/storage/objects_data.dart'
    show MediaObjectType;
import 'package:ourjourneys/models/storage/selected_file.dart'
    show SelectedFile;
import 'package:ourjourneys/shared/common/allowed_extensions.dart'
    show AllowedExtensions;
import 'package:ourjourneys/shared/common/file_enum.dart' show FileSizeUnit;
import 'package:ourjourneys/shared/errors_code_and_msg/platform_errors.dart';
import 'package:ourjourneys/shared/helpers/misc.dart' show FetchSourceMethod;
import 'package:ourjourneys/shared/views/screen_sizes.dart' show ScreenSize;
import 'package:path/path.dart' as path show extension;
import 'package:ourjourneys/services/configs/utils/files_picker_service.dart'
    show FilesPickerService;
import 'package:image/image.dart' as img
    show copyResize, decodeImage, encodeJpg;

extension on String {
  bool isNullOrEmpty(String? text) {
    return text == null || text.isEmpty;
  }

  // ignore: unused_element
  bool isNotNullOrEmpty(String? text) {
    return text != null && text.isNotEmpty;
  }
}

/// A utility class for various utility functions.
class Utils {
  Utils._(); // Private constructor to prevent instantiation

  /// capitalize the first letter of a given [text]
  static String capitalizeFirstLetter(String text) {
    if (text.isNullOrEmpty(text)) return '';
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Returns a custom document ID with a given type, user ID, and UTC timestamp.
  ///
  /// Example: "type-userId-timestamp"
  static String genCustomDocId({required String type, required String userId}) {
    return '$type-$userId-${DateTimeUtils.getUtcTimestampString()}';
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

  /// Utility function to retrieve a [String] of [ObjectsData.objectThumbnailKey] from a given [objectKey].
  ///
  /// Returns a [String] of the thumbnail key.
  /// Otherwise returns an empty [String].
  static String getThumbnailKeyFromObjectKey(String objectKey) {
    return "gen/thumbs/$objectKey";
  }

  /// Returns a folder path used to create an object key
  static String getFolderPath(String userId) {
    return "uploads/${DateTimeUtils.getUtcTimestampString()}-$userId";
  }
}

/// Utility class for interface related operations.
class InterfaceUtils {
  InterfaceUtils._(); // private constructor to prevent instantiation

  /// Utility function to determine the screen size of the device.
  /// Returns a [ScreenSize] enum value.
  static ScreenSize getScreenSize(double screenWidth) {
    if (screenWidth < 600) {
      return ScreenSize.small;
    } else if (screenWidth < 900) {
      return ScreenSize.medium;
    } else {
      return ScreenSize.large;
    }
  }

  static bool isBigScreen(BuildContext context) {
    return getScreenSize(MediaQuery.sizeOf(context).width) == ScreenSize.large;
  }

  /// this is a function that will scroll the scrollController to the top of the page
  static void scrollToTop(ScrollController scrollController,
      {Duration duration = const Duration(milliseconds: 300),
      Curve curve = Curves.easeInOutCirc}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.minScrollExtent,
          duration: duration,
          curve: curve,
        );
      }
    });
  }
}

/// Utility class for date and time related operations.
class DateTimeUtils {
  DateTimeUtils._(); // private constructor to prevent instantiation

  /// Returns nullable [DateTime] from the given [dateTimeString].
  static DateTime? parseDateTime(String? dateTimeString) {
    if (dateTimeString == null) return null;
    return DateTime.tryParse(dateTimeString);
  }

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
}

/// Utility class for file related operations.
class FileUtils {
  FileUtils._(); // Private constructor to prevent instantiation

  /// Converts a given byte value to a human-readable file size string.
  ///
  /// - [bytes]: The size of the file in bytes.
  ///
  /// - [desiredUnit]: Optional. The desired unit for the output (e.g., 'B', 'KB', 'MB', 'GB', 'TB').
  ///         If not provided, the method will automatically determine the best unit.
  ///
  /// - [decimalPlaces]: Optional. The number of decimal places to include in the result. Defaults to 2.
  ///
  /// - [throwErrorIfInvalid]: Optional. If true, throws an [ArgumentError] if the input size is less than 0. Defaults to false.
  ///
  /// Returns a formatted [String] representing the file size (e.g., "1.23 MB", "500 B"). if [throwErrorIfInvalid] is true, throws an [ArgumentError] if the input size is less than 0, otherwise returns an empty [String].
  static String formatBytes(int? bytes,
      {FileSizeUnit? desiredUnit,
      int decimalPlaces = 2,
      bool throwErrorIfInvalid = false}) {
    if (bytes == null || bytes < 0) {
      if (throwErrorIfInvalid) {
        throw ArgumentError.value(
            bytes, "bytes", "Invalid size [must be >= 0]");
      } else {
        return "";
      }
    }

    if (bytes == 0) {
      return "0 B";
    }

    const int k = 1024;
    final List<String> units = [
      FileSizeUnit.bytes.abbreviation,
      FileSizeUnit.kilobytes.abbreviation,
      FileSizeUnit.megabytes.abbreviation,
      FileSizeUnit.gigabytes.abbreviation,
      FileSizeUnit.terabytes.abbreviation,
      FileSizeUnit.petabytes.abbreviation
    ];

    if (desiredUnit != null) {
      final int unitIndex = units.indexOf(desiredUnit.abbreviation);
      if (unitIndex != -1) {
        double convertedValue = bytes / pow(k, unitIndex);
        return '${convertedValue.toStringAsFixed(decimalPlaces)} ${desiredUnit.abbreviation}';
      } else {
        // If the provided unit is invalid, default to automatic detection.
        // ignore: avoid_print
        print(
            "Warning: Invalid unit provided. Falling back to automatic unit detection.");
      }
    }

    int i = (log(bytes) / log(k)).floor();
    return '${(bytes / pow(k, i)).toStringAsFixed(decimalPlaces)} ${units[i]}';
  }

  /// Returns a detected file type from a mime type.
  /// Returns [MediaObjectType.unknown] if the mime type is not recognized.
  /// Returns [MediaObjectType.image] if the mime type is an image.
  /// Returns [MediaObjectType.video] if the mime type is a video.
  /// Returns [MediaObjectType.document] if the mime type starts with 'application/' or 'text/'.
  /// Returns [MediaObjectType.audio] if the mime type is an audio.
  static MediaObjectType detectFileTypeFromMimeType(String mimeType) {
    if (mimeType.startsWith('image/')) {
      return MediaObjectType.image;
    } else if (mimeType.startsWith('video/')) {
      return MediaObjectType.video;
    } else if (mimeType.startsWith('audio/')) {
      return MediaObjectType.audio;
    } else if (mimeType.startsWith('application/') ||
        mimeType.startsWith('text/')) {
      return MediaObjectType.document;
    } else {
      return MediaObjectType.unknown;
    }
  }

  /// Returns a detected file type from a file path.
  ///
  /// Returns [MediaObjectType.unknown] if the file type is not recognized.
  /// Returns [MediaObjectType.image] if the file type is an image.
  /// Returns [MediaObjectType.video] if the file type is a video.
  /// Returns [MediaObjectType.document] if the file type is a document.
  static MediaObjectType detectFileTypeFromFilepath(String filePath) {
    final filename = filePath.split('/').last;
    final mimeType = lookupMimeType(filename);

    if (mimeType == null) {
      return MediaObjectType.unknown;
    }

    if (mimeType.startsWith('image/')) {
      return MediaObjectType.image;
    } else if (mimeType.startsWith('video/')) {
      return MediaObjectType.video;
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
        return MediaObjectType.document;
      } else {
        return MediaObjectType.unknown;
      }
    } else {
      return MediaObjectType.unknown;
    }
  }

  /// Returns a mimetype from a file path.
  static String? detectMimeTypeFromFilepath(String filePath) {
    final filename = filePath.split('/').last;
    return lookupMimeType(filename);
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

  /// Utility function to pick local files from the device.
  ///
  /// consult [FilesPickerService.pickFiles] for more information.
  static Future<void> pickLocalFiles(
      {void Function()? onCompleted,
      required void Function(List<SelectedFile>) onFilesSelected,
      List<String> allowedExtensions = const [
        ...AllowedExtensions.imageCompactExtensions,
        ...AllowedExtensions.videoExtensions
      ]}) async {
    FilePickerResult? result;
    result = await FilesPickerService.pickFiles(
      allowMultiple: true,
      fileType: FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final picked = result.files
        .where((f) => f.bytes != null)
        .map((f) => SelectedFile(
            fetchSourceMethod: FetchSourceMethod.local, localFile: f.xFile))
        .toList();

    onFilesSelected(picked);

    onCompleted?.call();
  }

  /// Utility function to pick local photos or video from the device.
  ///
  /// consult [FilesPickerService.pickPhotosOrVideos] for more information.
  static Future<void> pickLocalPhotosOrVideos({
    void Function()? onCompleted,
    required void Function(List<SelectedFile>) onMediaSelected,
    bool allowMultiple = true,
    ImageSource mediaSource = ImageSource.gallery,
    bool fullMetaData = true,
    int? photoQuality,
    double? photoMaxWidth,
    double? photoMaxHeight,
    int? limit,
    MediaObjectType mediaType = MediaObjectType.imageOrVideo,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? videoMaxDuration,
  }) async {
    if (PlatformDetectionService.isMobile) {
      List<XFile> result = await FilesPickerService.pickPhotosOrVideos(
        allowMultiple: allowMultiple,
        mediaSource: mediaSource,
        fullMetaData: fullMetaData,
        photoQuality: photoQuality,
        photoMaxWidth: photoMaxWidth,
        photoMaxHeight: photoMaxHeight,
        limit: limit,
        mediaType: mediaType,
        preferredCameraDevice: preferredCameraDevice,
        videoMaxDuration: videoMaxDuration,
      );

      if (result.isEmpty) return;

      final picked = result
          .map((f) => SelectedFile(
              fetchSourceMethod: FetchSourceMethod.local, localFile: f))
          .toList();

      onMediaSelected(picked);
    } else {
      throw CustomPlatformException(
          errorEnum: PlatformErrors.PLAT_C01,
          process: FileUtils.pickLocalPhotosOrVideos.runtimeType.toString(),
          errorDetailsFromDependency:
              "Attempt to pick photos or videos on platform: '${PlatformDetectionService.currentPlatform}'");
    }

    onCompleted?.call();
  }

  /// Utility function to compress an image.
  static Uint8List compressImage(
    Uint8List originalBytes, {
    int maxDimension = 1080,
    int quality = 70,
  }) {
    final image = img.decodeImage(originalBytes);
    if (image == null) throw Exception("Invalid image");

    final resized = img.copyResize(image,
        width: maxDimension, maintainAspect: true); // maintains aspect ratio
    final compressed =
        img.encodeJpg(resized, quality: quality); // compress image

    return Uint8List.fromList(compressed);
  }

  /// Utility function to generate a thumbnail from a given [Uint8List].
  static Uint8List generateThumbnail(Uint8List originalBytes) {
    return compressImage(originalBytes, maxDimension: 300, quality: 60);
  }

  /// Utility function to generate a checksum from a given [Uint8List]
  /// using the md5 algorithm.
  static String generateChecksum(Uint8List data) {
    return md5.convert(data).toString();
  }
}
