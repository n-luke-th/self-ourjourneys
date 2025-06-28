/// lib/components/image_video_viewer/image_renderer.dart

import 'package:extended_image/extended_image.dart'
    show ExtendedImage, LoadState;
import 'package:flutter/material.dart';
// import 'package:logger/logger.dart' show Logger;
import 'package:ourjourneys/components/method_components.dart'
    show MethodsComponents;
// import 'package:ourjourneys/helpers/dependencies_injection.dart' show getIt;
import 'package:ourjourneys/models/interface/image_display_configs_model.dart';
import 'package:ourjourneys/models/storage/fetch_source_data.dart';
import 'package:ourjourneys/services/core/image_provider_cache.dart';
import 'package:provider/provider.dart';

/// The [ImageRenderer] widget is a wrapper around the [ExtendedImage] to display the image from the appropriate source with given configurations.
///
/// driving by the [ImageProviderCache] under the hood.
class ImageRenderer extends StatelessWidget {
  /// tells how to fetch the image from, also included all the necessary data to fetch the image from the source
  final FetchSourceData fetchSourceData;

  /// the configurations for display the image
  final ImageDisplayConfigsModel imageRendererConfigs;

  const ImageRenderer({
    super.key,
    required this.fetchSourceData,
    required this.imageRendererConfigs,
  });

  ExtendedImage _buildImage(
    BuildContext ctx,
    ImageProvider<Object> provider,
  ) {
    // final Logger _logger = getIt<Logger>();
    return ExtendedImage(
      key: ValueKey(fetchSourceData.uniqueIdentityKey),
      image: provider,
      width: imageRendererConfigs.width,
      height: imageRendererConfigs.height,
      mode: imageRendererConfigs.displayImageMode,
      fit: imageRendererConfigs.fit,
      shape: BoxShape.rectangle,
      filterQuality: imageRendererConfigs.filterQuality,
      enableLoadState: true,
      handleLoadingProgress: true,
      loadStateChanged: (state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            // _logger.i("image is loading...");
            return Container(
              alignment: Alignment.center,
              child: MethodsComponents.renderShimmerEffect(
                baseColor: imageRendererConfigs.shimmerColor,
                shimmerBaseOpacity: imageRendererConfigs.shimmerBaseOpacity,
                height: imageRendererConfigs.height,
                width: imageRendererConfigs.width,
              ),
            );
          case LoadState.completed:
            // _logger.i("image is loaded");
            return state.completedWidget;
          case LoadState.failed:
            // _logger.e("image loading failed");
            if (imageRendererConfigs.shouldShowRetryButton) {
              return Builder(builder: (ctx) {
                return Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    imageRendererConfigs.errorBuilder?.call(
                          ctx,
                          state.lastException!,
                          state.lastStack,
                        ) ??
                        imageRendererConfigs.errorWidget,
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: GestureDetector(
                          onTap: () => state.reLoadImage(),
                          child: imageRendererConfigs.retryButton ??
                              TextButton.icon(
                                  icon: const Icon(Icons.refresh_outlined),
                                  onPressed: () => state.reLoadImage(),
                                  label: const Text("Retry"))),
                    ),
                  ],
                );
              });
            }
            return imageRendererConfigs.errorBuilder?.call(
                  ctx,
                  state.lastException!,
                  state.lastStack,
                ) ??
                imageRendererConfigs.errorWidget;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ImageProvider<Object>>(
      future: context
          .read<ImageProviderCache>()
          .getProvider(fetchSourceData, imageRendererConfigs),
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return MethodsComponents.renderShimmerEffect(
            baseColor: imageRendererConfigs.shimmerColor,
            shimmerBaseOpacity: imageRendererConfigs.shimmerBaseOpacity,
            height: imageRendererConfigs.height,
            width: imageRendererConfigs.width,
          );
        }
        if (snap.hasError) {
          return imageRendererConfigs.errorBuilder?.call(
                ctx,
                snap.error!,
                snap.stackTrace,
              ) ??
              imageRendererConfigs.errorWidget;
        }
        return _buildImage(ctx, snap.data!);
      },
    );
  }
}
