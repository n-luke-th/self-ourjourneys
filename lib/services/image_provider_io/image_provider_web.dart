/// lib/services/image_provider_io/image_provider_web.dart
///
/// Image Provider Web
///
/// only for web
///
/// provides the dummy image provider io for web
/// for build purpose only
///
/// for mobile use `lib/services/image_provider_io/image_provider_io.dart`
import 'dart:typed_data' show Uint8List;

import 'package:extended_image/extended_image.dart'
    show ExtendedMemoryImageProvider;
import 'package:flutter/widgets.dart' show ImageProvider;
import 'package:image_picker/image_picker.dart' show XFile;

ImageProvider localFileImageProvider(XFile file) {
  return ExtendedMemoryImageProvider(Uint8List.fromList([0, 0, 0, 0]),
      imageCacheName: file.name);
}
