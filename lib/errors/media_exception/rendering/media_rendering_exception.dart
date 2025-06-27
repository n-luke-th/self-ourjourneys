/// lib/errors/media_exception/rendering/media_rendering_exception.dart
/// Media rendering exceptions
import 'package:ourjourneys/errors/base/base_exception.dart';

/// exception for cloud object-related errors
class MediaRenderingException extends BaseException {
  MediaRenderingException(
      {super.error,
      super.st,
      super.errorDetailsFromDependency,
      super.process,
      required super.errorEnum});
}
