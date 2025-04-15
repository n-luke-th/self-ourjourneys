/// lib/shared/common/file_picker_enum.dart
///
///

enum FilePickerMode {
  /// meant to support only image file type
  ///
  /// opens the platform photo library
  photoPicker,

  /// meant to support any file type
  ///
  /// opens the platform file picker
  filePicker,
}

class AllowedExtensions {
  /// List of allowed image extensions
  static const List<String> imageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'svg'
  ];

  /// List of allowed video extensions
  static const List<String> videoExtensions = ['mp4', 'mov', 'avi', 'mpeg'];

  /// List of allowed audio extensions
  static const List<String> audioExtensions = ['mp3', 'wav'];

  /// List of allowed document extensions
  static const List<String> documentExtensions = ['txt', 'json', 'pdf'];
}
