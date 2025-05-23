/// lib/shared/common/file_picker_enum.dart
///
///

// enum FilePickerMode {
//   /// meant to support only image file type
//   ///
//   /// opens the platform photo library
//   photoPicker,

//   /// meant to support any file type
//   ///
//   /// opens the platform file picker
//   filePicker,
// }

class AllowedExtensions {
  /// List of allowed image extensions: jpg, jpeg, png, gif
  static const List<String> imageCompactExtensions = [
    'jpg',
    'jpeg',
    'png',
    'heic',
    'gif',
  ];

  /// List of allowed image extensions: jpg, jpeg, png, gif, webp, svg
  static const List<String> imagePlusExtensions = [
    ...imageCompactExtensions,
    'webp',
    'svg'
  ];

  /// List of allowed video extensions: mp4, mov, avi, mpeg
  static const List<String> videoExtensions = ['mp4', 'mov', 'avi', 'mpeg'];

  /// List of allowed audio extensions: mp3, wav
  static const List<String> audioExtensions = ['mp3', 'wav'];

  /// List of allowed document extensions:  txt, json, pdf
  static const List<String> documentExtensions = ['txt', 'json', 'pdf'];
}
