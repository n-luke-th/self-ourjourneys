/// lib/helpers/get_platform_service.dart
///
///

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_io/io.dart';
import 'package:ourjourneys/shared/helpers/platform_enum.dart';

class PlatformDetectionService {
  static final _instance = PlatformDetectionService._internal();

  factory PlatformDetectionService() => _instance;

  PlatformDetectionService._internal();

  PlatformEnum get currentPlatform {
    if (kIsWeb) {
      return PlatformEnum.web;
    } else if (Platform.isIOS) {
      return PlatformEnum.iOS;
    } else if (Platform.isAndroid) {
      return PlatformEnum.android;
    } else {
      return PlatformEnum.unsupportedError;
    }
  }

  String get readableCurrentPlatform {
    switch (currentPlatform) {
      case PlatformEnum.web:
        return 'Web';
      case PlatformEnum.iOS:
        return 'iOS';
      case PlatformEnum.android:
        return 'Android';
      default:
        return 'unsupportedError';
    }
  }
}
