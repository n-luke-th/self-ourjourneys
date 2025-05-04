import 'package:file_picker/file_picker.dart'
    show FilePicker, FilePickerResult, FileType;

class FilesPickerUtils {
  /// Pick files from device
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
}
