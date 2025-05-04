/// lib/models/storage/selected_file.dart
///

import 'dart:typed_data' show Uint8List;

import 'package:file_picker/file_picker.dart' show PlatformFile;

class SelectedFile {
  final PlatformFile file;
  final Uint8List bytes;

  SelectedFile({required this.file, required this.bytes});
}
