/// lib/components/image_video_viewer/image_renderer.dart

import 'dart:typed_data' show Uint8List;

import 'package:extended_image/extended_image.dart'
    show
        ExtendedFileImageProvider,
        ExtendedImage,
        ExtendedImageState,
        ExtendedMemoryImageProvider,
        ExtendedNetworkImageProvider,
        LoadState;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:logger/logger.dart' show Logger;
import 'package:ourjourneys/errors/local_storage_exception/local_storage_exception.dart'
    show LocalStorageException;

import 'package:ourjourneys/models/interface/base_image_configs.dart';
import 'package:ourjourneys/components/method_components.dart'
    show MethodsComponents;
import 'package:ourjourneys/errors/object_storage_exception/cloud_object_storage_exception.dart';
import 'package:ourjourneys/helpers/dependencies_injection.dart' show getIt;
import 'package:ourjourneys/models/interface/image_display_configs_model.dart';
import 'package:ourjourneys/models/storage/fetch_source_data.dart';
import 'package:ourjourneys/services/auth/acc/auth_wrapper.dart';
import 'package:ourjourneys/shared/errors_code_and_msg/cloud_object_storage_errors.dart';
import 'package:ourjourneys/shared/errors_code_and_msg/local_storage_errors.dart';
import 'package:ourjourneys/shared/helpers/misc.dart' show FetchSourceMethod;
import 'package:ourjourneys/shared/services/network_const.dart'
    show NetworkConsts;
import 'package:universal_io/io.dart' show File, HttpException;

/// The [ImageRenderer] widget is a wrapper around the [ExtendedImage] to display the image from the appropriate source with given configurations.
class ImageRenderer extends StatefulWidget with BaseImageConfigs {
  /// tells how to fetch the image from, also included all the necessary data to fetch the image from the source
  final FetchSourceData fetchSourceData;

  @override
  final ImageDisplayConfigsModel imageRendererConfigs;

  const ImageRenderer({
    super.key,
    required this.fetchSourceData,
    required this.imageRendererConfigs,
  });

  @override
  State<ImageRenderer> createState() => _ImageRendererState();
}

class _ImageRendererState extends State<ImageRenderer> with BaseImageConfigs {
  final AuthWrapper _authWrapper = getIt<AuthWrapper>();
  final Logger _logger = getIt<Logger>();
  late final String _idToken;

  FetchSourceData get fetchSourceData => widget.fetchSourceData;

  @override
  ImageDisplayConfigsModel get imageRendererConfigs =>
      widget.imageRendererConfigs;

  @override
  void initState() {
    super.initState();
    _authWrapper.refreshIdToken();
    _idToken = _authWrapper.idToken ?? "";
  }

  /// provide the base image renderer with the given image provider.
  ExtendedImage _baseImageRenderer(BuildContext context,
      {required ImageProvider<Object> imageProvider}) {
    return ExtendedImage(
      image: imageProvider,
      width: imageRendererConfigs.width,
      height: imageRendererConfigs.height,
      mode: imageRendererConfigs.displayImageMode,
      fit: imageRendererConfigs.fit,
      shape: BoxShape.rectangle,
      filterQuality: imageRendererConfigs.filterQuality,
      enableLoadState: true,
      handleLoadingProgress: true,
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return MethodsComponents.renderShimmerEffect(
                baseColor: imageRendererConfigs.shimmerColor,
                shimmerBaseOpacity: imageRendererConfigs.shimmerBaseOpacity,
                height: imageRendererConfigs.height,
                width: imageRendererConfigs.width);
          case LoadState.completed:
            return state.completedWidget;
          case LoadState.failed:
            if (imageRendererConfigs.errorBuilder != null) {
              return imageRendererConfigs.errorBuilder!(
                  context, state.lastException!, state.lastStack);
            } else {
              return imageRendererConfigs.errorWidget!;
            }
        }
      },
    );
  }

  /// render the image.
  /// the image can be fetched from the server or from the local storage:
  /// - if the image is fetched from the server, the [objectKey] is required.
  /// - if the image is fetched from the local storage, the [bytes] or [file] is required.
  ExtendedImage _renderImage(BuildContext context,
      {String? idToken, String? objectKey, Uint8List? bytes, XFile? file}) {
    switch (fetchSourceData.fetchSourceMethod) {
      case FetchSourceMethod.server:
        assert(objectKey != null && idToken != null);
        _logger.d("render using 'ExtendedNetworkImageProvider'");
        return _baseImageRenderer(context,
            imageProvider: ExtendedNetworkImageProvider(
              "${NetworkConsts.cdnUrl}/$objectKey",
              headers: {
                NetworkConsts.headerAuthorization:
                    '${NetworkConsts.headerAuthorizationBearer} $idToken',
              },
              scale: 1.0,
              cache: imageRendererConfigs.allowCache,
              cacheKey: objectKey.hashCode.toString(),
              cacheMaxAge: const Duration(days: 15),
              timeRetry: const Duration(milliseconds: 500),
            ));
      case FetchSourceMethod.local:
        assert(file != null || bytes != null);
        if (file != null) {
          _logger.d("render using 'ExtendedFileImageProvider'");
          return _baseImageRenderer(context,
              imageProvider: ExtendedFileImageProvider(File(file.path),
                  imageCacheName: file.name));
        } else if (bytes != null) {
          // render image using bytes by loading the entire image file into memory.
          // significant performance consumption, avoid using.
          _logger.d("render using 'ExtendedMemoryImageProvider'");
          return _baseImageRenderer(context,
              imageProvider: ExtendedMemoryImageProvider(bytes));
        } else {
          // TODO: add the app custom exception
          throw ArgumentError(
              "'file' or 'bytes' is required to render the image");
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    _logger.d(
        "Building 'ImageRender' for objectKey: '${fetchSourceData.cloudFileObjectKey}', allowCache: '${imageRendererConfigs.allowCache}', fetchSourceMethod: '${fetchSourceData.fetchSourceMethod.stringValue}', displayImageMode: '${imageRendererConfigs.displayImageMode}', quality: '${imageRendererConfigs.filterQuality}', fit: '${imageRendererConfigs.fit}', width: '${imageRendererConfigs.width}', height: '${imageRendererConfigs.height}'");
    switch (fetchSourceData.fetchSourceMethod) {
      case FetchSourceMethod.server:
        try {
          return _renderImage(context,
              objectKey: fetchSourceData.cloudFileObjectKey, idToken: _idToken);
        } on HttpException catch (e) {
          throw CloudObjectStorageException(
            error: e,
            st: StackTrace.current,
            errorDetailsFromDependency: 'Failed to load image from server',
            errorEnum: CloudObjectStorageErrors.CLOS_S02,
          );
        } on Exception catch (e) {
          throw CloudObjectStorageException(
            error: e,
            st: StackTrace.current,
            errorDetailsFromDependency: 'Failed to load image from server',
            errorEnum: CloudObjectStorageErrors.CLOS_U00,
          );
        }
      case FetchSourceMethod.local:
        try {
          return _renderImage(context,
              file: fetchSourceData.localFile,
              bytes: fetchSourceData.localFileBytes);
        } on ArgumentError catch (e) {
          throw LocalStorageException(
              errorEnum: LocalStorageErrors.LOCS_C01,
              error: e,
              errorDetailsFromDependency: e.toString());
        } on Exception catch (e) {
          throw LocalStorageException(
            error: e,
            st: StackTrace.current,
            errorDetailsFromDependency:
                'Failed to load image from local storage',
            errorEnum: LocalStorageErrors.LOCS_U00,
          );
        }
    }
  }
}
