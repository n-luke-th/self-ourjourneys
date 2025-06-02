/// lib/services/configs/utils/files_picker_service.dart
/// service class for files picker operations

import 'package:file_picker/file_picker.dart'
    show FilePicker, FilePickerResult, FileType;
import 'package:image_picker/image_picker.dart'
    show ImagePicker, ImageSource, XFile, CameraDevice;
import 'package:ourjourneys/models/storage/objects_data.dart';

/// A service class for files picker operations.
class FilesPickerService {
  /// Pick any files from device
  ///
  /// consult [FilePicker.platform.pickFiles] for more details
  static Future<FilePickerResult?> pickFiles(
      {FileType fileType = FileType.any,
      List<String>? allowedExtensions,
      bool withData = true,
      bool allowMultiple = true}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple,
      type: fileType,
      allowedExtensions: allowedExtensions,
      withData: withData,
    );
    return result;
  }

  /// Pick photos or video from device
  ///
  /// Returns a list of [XFile] objects
  ///
  /// [allowMultiple] is effective only if [mediaType] is [MediaObjectType.image] or [MediaObjectType.imageOrVideo]
  ///
  /// [mediaType] can be one of the following:
  /// - [MediaObjectType.image]
  /// - [MediaObjectType.video]
  /// - [MediaObjectType.imageOrVideo]
  ///
  /// [photoQuality] is effective only if [mediaType] is [MediaObjectType.image] or [MediaObjectType.imageOrVideo]
  ///
  /// [photoMaxWidth] is effective only if [mediaType] is [MediaObjectType.image] or [MediaObjectType.imageOrVideo]
  ///
  /// [limit] is effective only if [mediaType] is [MediaObjectType.image] or [MediaObjectType.imageOrVideo] and [allowMultiple] is true
  ///
  /// [videoMaxDuration] is effective only if [mediaType] is [MediaObjectType.video]
  static Future<List<XFile>> pickPhotosOrVideos({
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
    assert(
        mediaType == MediaObjectType.image ||
            mediaType == MediaObjectType.video ||
            mediaType == MediaObjectType.imageOrVideo,
        "mediaType must be 'image', 'video' or 'imageOrVideo'");

    final ImagePicker picker = ImagePicker();
    switch (mediaType) {
      //
      case MediaObjectType.image:
        if (allowMultiple) {
          final List<XFile> images = await picker.pickMultiImage(
              requestFullMetadata: fullMetaData,
              imageQuality: photoQuality,
              limit: limit,
              maxHeight: photoMaxHeight,
              maxWidth: photoMaxWidth);

          return images;
        } else {
          final XFile? image = await picker.pickImage(
              source: mediaSource,
              requestFullMetadata: fullMetaData,
              imageQuality: photoQuality,
              maxHeight: photoMaxHeight,
              maxWidth: photoMaxWidth);
          if (image != null) {
            return [image];
          } else {
            return [];
          }
        }
      //
      case MediaObjectType.video:
        if (allowMultiple) {
        } else {
          final XFile? video = await picker.pickVideo(
              source: mediaSource,
              maxDuration: videoMaxDuration,
              preferredCameraDevice: preferredCameraDevice);
          if (video != null) {
            return [video];
          } else {
            return [];
          }
        }
      default:
        if (allowMultiple) {
          final List<XFile> multipleMedia = await picker.pickMultipleMedia(
              requestFullMetadata: fullMetaData,
              imageQuality: photoQuality,
              maxHeight: photoMaxHeight,
              maxWidth: photoMaxWidth,
              limit: limit);
          return multipleMedia;
        } else {
          final XFile? media = await picker.pickMedia(
              requestFullMetadata: fullMetaData,
              imageQuality: photoQuality,
              maxHeight: photoMaxHeight,
              maxWidth: photoMaxWidth);
          if (media != null) {
            return [media];
          } else {
            return [];
          }
        }
    }
    return [];
  }
}
