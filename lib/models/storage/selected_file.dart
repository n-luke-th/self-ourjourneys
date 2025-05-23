/// lib/models/storage/selected_file.dart
///

import 'package:file_picker/file_picker.dart' show PlatformFile;
import 'package:ourjourneys/models/storage/objects_data.dart' show ObjectsData;
import 'package:ourjourneys/shared/helpers/misc.dart' show FetchSourceMethod;

class SelectedFile {
  final PlatformFile? localFile;
  final ObjectsData? cloudObjectData;
  final FetchSourceMethod fetchSourceMethod;

  SelectedFile(
      {this.localFile, this.cloudObjectData, required this.fetchSourceMethod}) {
    if (localFile?.bytes == null &&
        fetchSourceMethod == FetchSourceMethod.local) {
      throw Exception('SelectedFile: file.bytes is null');
    }
    if (cloudObjectData == null &&
        FetchSourceMethod.server == fetchSourceMethod) {
      throw Exception('SelectedFile: cloudObjectId is null');
    }
  }
}
