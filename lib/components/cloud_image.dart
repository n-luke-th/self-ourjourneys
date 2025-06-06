/// lib/components/cloud_image.dart
// TODO: enhance performance for image widget

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart' show Logger;
import 'package:shimmer/shimmer.dart';

import 'package:ourjourneys/errors/object_storage_exception/cloud_object_storage_exception.dart';
import 'package:ourjourneys/helpers/dependencies_injection.dart' show getIt;
import 'package:ourjourneys/services/auth/acc/auth_wrapper.dart';
import 'package:ourjourneys/shared/errors_code_and_msg/cloud_object_storage_errors.dart';
import 'package:ourjourneys/shared/services/network_const.dart';

/// The [CloudImage] widget is a wrapper around the Image widget that allows for caching of images fetched from a server.
/// used to handle display the images from the cloud storage
class CloudImage extends StatefulWidget {
  final String objectKey;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Duration fadeDuration;
  final Widget? errorWidget;
  final double shimmerBaseOpacity;
  final FilterQuality filterQuality;
  final Widget Function(
      BuildContext context, Object error, StackTrace? stackTrace)? errorBuilder;

  /// Allow caching of the image, also attempts to load from cache first
  final bool allowCache;

  final ExtendedImageMode displayImageMode;

  const CloudImage({
    super.key,
    required this.objectKey,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.fadeDuration = const Duration(milliseconds: 500),
    this.errorWidget = const Center(child: Icon(Icons.error_outline)),
    this.shimmerBaseOpacity = 0.5,
    this.filterQuality = FilterQuality.medium,
    this.allowCache = true,
    this.errorBuilder,
    this.displayImageMode = ExtendedImageMode.none,
  });

  @override
  State<CloudImage> createState() => _CloudImageState();
}

class _CloudImageState extends State<CloudImage> with TickerProviderStateMixin {
  final AuthWrapper _authWrapper = getIt<AuthWrapper>();
  final Logger _logger = getIt<Logger>();

  late final String _idToken;

  @override
  void initState() {
    super.initState();
    _authWrapper.refreshIdToken();
    _idToken = _authWrapper.idToken ?? '';
  }

  @override
  Widget build(BuildContext context) {
    try {
      _logger.d(
          "Building CloudImage widget for objectKey: '${widget.objectKey}', allowCache: '${widget.allowCache}'");
      return ExtendedImage.network(
        "${NetworkConsts.cdnUrl}/${widget.objectKey}",
        headers: {
          NetworkConsts.headerAuthorization:
              '${NetworkConsts.headerAuthorizationBearer} $_idToken',
        },
        width: widget.width,
        height: widget.height,
        mode: widget.displayImageMode,
        fit: widget.fit,
        cache: widget.allowCache,
        cacheKey: widget.objectKey.hashCode.toString(),
        cacheMaxAge: const Duration(days: 15),
        // border: BoxBorder.all(color: Colors.blueGrey),
        shape: BoxShape.rectangle,
        // borderRadius: UiConsts.BorderRadiusCircular_superLarge,
        filterQuality: widget.filterQuality,
        timeRetry: const Duration(milliseconds: 500),
        enableLoadState: true,
        loadStateChanged: (ExtendedImageState state) {
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              return _buildShimmer();
            case LoadState.completed:
              return state.completedWidget;
            case LoadState.failed:
              if (widget.errorBuilder != null) {
                return widget.errorBuilder!(
                    context, state.lastException!, state.lastStack);
              } else {
                return widget.errorWidget!;
              }
          }
        },
      );
    } on Exception catch (e) {
      throw CloudObjectStorageException(
        error: e,
        st: StackTrace.current,
        errorDetailsFromDependency: 'Failed to load image from server',
        errorEnum: CloudObjectStorageErrors.CLOS_S01,
      );
    }
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.withValues(alpha: widget.shimmerBaseOpacity),
      highlightColor: Colors.white.withValues(alpha: widget.shimmerBaseOpacity),
      child: Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[300],
      ),
    );
  }
}
