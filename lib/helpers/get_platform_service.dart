/// lib/helpers/get_platform_service.dart
///
/// a helper service to detect the platform and related info

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_io/io.dart' show Platform;
import 'package:ourjourneys/shared/helpers/platform_enum.dart';

class PlatformDetectionService {
  static final _instance = PlatformDetectionService._internal();

  factory PlatformDetectionService() => _instance;

  PlatformDetectionService._internal();

  static bool get isWeb => kIsWeb;

  static bool get isMobile =>
      !kIsWeb && currentPlatform != PlatformEnum.unsupportedError;

  static PlatformEnum get currentPlatform {
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

  static String get readableCurrentPlatform {
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
