/// lib/models/interface/image_display_configs_model.dart
///
import 'package:extended_image/extended_image.dart' show ExtendedImageMode;
import 'package:flutter/material.dart'
    show
        BoxFit,
        BuildContext,
        Center,
        Color,
        Colors,
        FilterQuality,
        Icon,
        Icons,
        Widget;

/// the model for the image display configs
/// tells how image would be rendered to the user.
///
/// did not handle how the image is gathered from source, for that refer to [FetchSourceData].
///
class ImageDisplayConfigsModel {
  /// how the image would be rendered in the image viewer
  final BoxFit fit;

  /// the expected width of the image
  final double? width;

  /// the expected height of the image
  final double? height;

  /// the opacity of the shimmer effect
  final double shimmerBaseOpacity;

  /// the color of the shimmer effect
  final Color shimmerColor;

  /// the quality of the image that will be rendered
  final FilterQuality filterQuality;

  /// Allow caching of the image, also attempts to load from cache first
  final bool allowCache;

  /// the mode that the image would be in the image viewer
  final ExtendedImageMode displayImageMode;

  /// the widget to be displayed when there is an error fetching the image.
  /// ignored if [errorBuilder] is provided
  final Widget errorWidget;

  /// the builder function to be called when there is an error fetching the image.
  ///
  /// the function takes the precedence over the [errorWidget]
  final Widget Function(
      BuildContext context, Object error, StackTrace? stackTrace)? errorBuilder;

  const ImageDisplayConfigsModel({
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.shimmerBaseOpacity = 0.5,
    this.shimmerColor = Colors.grey,
    this.filterQuality = FilterQuality.medium,
    this.allowCache = true,
    this.displayImageMode = ExtendedImageMode.none,
    this.errorWidget = const Center(child: Icon(Icons.error_outline)),
    this.errorBuilder,
  });

  Map<String, dynamic> toMap() {
    return {
      'fit': fit.toString(),
      'width': width,
      'height': height,
      'shimmerBaseOpacity': shimmerBaseOpacity,
      'shimmerColor': shimmerColor.toString(),
      'filterQuality': filterQuality.toString(),
      'allowCache': allowCache,
      'displayImageMode': displayImageMode.toString(),
      'errorWidget': errorWidget.toString(),
      'errorBuilder': errorBuilder.toString(),
    };
  }
}
