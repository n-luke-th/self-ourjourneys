/// lib/models/storage/fetch_source_data.dart
import 'dart:typed_data' show Uint8List;

import 'package:image_picker/image_picker.dart' show XFile;
import 'package:ourjourneys/shared/helpers/misc.dart' show FetchSourceMethod;

/// A model class to hold data for fetching media source
///
class FetchSourceData {
  /// determine the source to fetch the media from, either the cloud storage or local storage
  final FetchSourceMethod fetchSourceMethod;

  /// the local file path if the source is local
  final XFile? localFile;

  /// the byte of the file as local source alternative
  final Uint8List? localFileBytes;

  /// the cloud file objecy key if the source is cloud
  final String? cloudFileObjectKey;

  FetchSourceData({
    required this.fetchSourceMethod,
    this.localFile,
    this.localFileBytes,
    this.cloudFileObjectKey,
  }) {
    switch (fetchSourceMethod) {
      case FetchSourceMethod.local:
        assert(localFile != null || localFileBytes != null);
        if (localFile == null) {
          throw ArgumentError.value(localFile, "localFile",
              "'localFile' must be provided if the 'fetchSourceMethod' is 'local'");
        } else if (localFileBytes == null) {
          throw ArgumentError.value(localFileBytes, "localFileBytes",
              "'localFileBytes' must be provided if the 'fetchSourceMethod' is 'local'");
        }
        break;
      case FetchSourceMethod.server:
        if (cloudFileObjectKey == null) {
          throw ArgumentError.value(cloudFileObjectKey, "cloudFileObjectKey",
              "'cloudFileObjectKey' must be provided if the 'fetchSourceMethod' is 'server'");
        }
        break;
    }
  }
}
