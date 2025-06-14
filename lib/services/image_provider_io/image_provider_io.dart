/// lib/services/image_provider_io/image_provider_io.dart
///
/// Image Provider IO
///
/// only for mobile
///
/// provides the actual image provider io for mobile
///
/// for web use `lib/services/image_provider_io/image_provider_web.dart`
import 'dart:io' show File;
import 'package:extended_image/extended_image.dart'
    show ExtendedFileImageProvider;
import 'package:flutter/widgets.dart' show ImageProvider;
import 'package:image_picker/image_picker.dart' show XFile;

/// returns the image provider for the given file on mobile devices
///
/// if web, returns a dummy image provider
ImageProvider localFileImageProvider(XFile file) {
  return ExtendedFileImageProvider(File(file.path), imageCacheName: file.name);
}
