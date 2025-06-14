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
        break;
      case FetchSourceMethod.server:
        assert(cloudFileObjectKey != null);
        break;
    }
  }

  /// attempt to get the [Uint8List]
  /// from the [localFile]
  Future<Uint8List?> get localFileAsUint8List async {
    if (localFile != null) {
      return await localFile!.readAsBytes();
    } else {
      return null;
    }
  }
}
