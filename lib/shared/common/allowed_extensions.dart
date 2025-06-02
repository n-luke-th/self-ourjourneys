/// lib/shared/common/allowed_extensions.dart
///
/// List of allowed extensions
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
