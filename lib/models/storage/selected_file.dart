/// lib/models/storage/selected_file.dart
///

import 'package:image_picker/image_picker.dart' show XFile;
import 'package:ourjourneys/models/storage/objects_data.dart' show ObjectsData;
import 'package:ourjourneys/shared/helpers/misc.dart' show FetchSourceMethod;

class SelectedFile {
  final XFile? localFile;
  final ObjectsData? cloudObjectData;
  final FetchSourceMethod fetchSourceMethod;

  SelectedFile(
      {this.localFile, this.cloudObjectData, required this.fetchSourceMethod}) {
    if (localFile?.length() == null &&
        fetchSourceMethod == FetchSourceMethod.local) {
      throw Exception('SelectedFile: file.bytes is null');
    }
    if (cloudObjectData == null &&
        FetchSourceMethod.server == fetchSourceMethod) {
      throw Exception('SelectedFile: cloudObjectId is null');
    }
  }
}
