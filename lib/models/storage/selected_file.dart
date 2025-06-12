/// lib/models/storage/selected_file.dart
///

import 'package:image_picker/image_picker.dart' show XFile;
import 'package:ourjourneys/models/storage/objects_data.dart' show ObjectsData;
import 'package:ourjourneys/shared/helpers/misc.dart' show FetchSourceMethod;

/// the model for the selected file to be uploaded or picked for processing
class SelectedFile {
  final XFile? localFile;
  final ObjectsData? cloudObjectData;

  /// determine the source the media from, either the cloud storage or local storage
  final FetchSourceMethod fetchSourceMethod;

  SelectedFile(
      {this.localFile, this.cloudObjectData, required this.fetchSourceMethod}) {
    if (localFile?.length() == null &&
        fetchSourceMethod == FetchSourceMethod.local) {
      throw ArgumentError('SelectedFile: file.bytes is null');
    }
    if (cloudObjectData == null &&
        FetchSourceMethod.server == fetchSourceMethod) {
      throw ArgumentError('SelectedFile: cloudObjectId is null');
    }
  }
}
