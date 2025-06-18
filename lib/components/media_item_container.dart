/// lib/components/media_item_container.dart
///

import 'package:flutter/material.dart';
import 'package:logger/logger.dart' show Logger;
import 'package:ourjourneys/helpers/dependencies_injection.dart' show getIt;
import 'package:ourjourneys/helpers/utils.dart' show FileUtils;
import 'package:ourjourneys/models/interface/image_display_configs_model.dart';
import 'package:ourjourneys/models/storage/fetch_source_data.dart';
import 'package:ourjourneys/models/storage/objects_data.dart'
    show MediaObjectType;
import 'package:video_player/video_player.dart';

import 'package:ourjourneys/components/image_video_viewer/image_renderer.dart';
import 'package:ourjourneys/shared/views/ui_consts.dart';

/// media item container
///
/// component for displaying media items (images, videos, etc.)
/// - for images, using [ImageRenderer]
/// - for videos, using [VideoPlayer]
class MediaItemContainer extends StatelessWidget {
  final String mimeType;

  /// tells how to fetch the media from, also included all the necessary data to fetch the media from the source
  final FetchSourceData fetchSourceData;

  final bool showActionWidget;
  final Widget? actionWidget;
  final Alignment actionWidgetPlace;
  final VoidCallback? onActionWidgetTriggered;
  final double widgetRatio;
  final double? height;
  final double? width;
  final double? mediaRatio;
  final BoxShape shape;
  final bool showDescriptionBar;
  final int descriptionTxtMaxLines;
  final (int, int) mediaAndDescriptionBarFlexValue;
  final Map<String, dynamic>? extraMapData;
  final bool showWidgetBorder;
  final BoxBorder? widgetBorder;

  // gesture callbacks
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  // final void Function(PointerHoverEvent)? onHover;

  /// the configs for the image to be displayed
  final ImageDisplayConfigsModel imageRendererConfigs;

  const MediaItemContainer({
    super.key,
    required this.mimeType,
    required this.fetchSourceData,
    this.showActionWidget = false,
    this.actionWidget,
    this.actionWidgetPlace = Alignment.topRight,
    this.onActionWidgetTriggered,
    this.widgetRatio = 10 / 16,
    this.height,
    this.width,
    this.mediaRatio,
    this.shape = BoxShape.rectangle,
    this.showDescriptionBar = true,
    this.descriptionTxtMaxLines = 3,
    this.mediaAndDescriptionBarFlexValue = (3, 1),
    this.extraMapData,
    this.showWidgetBorder = true,
    this.widgetBorder,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    // this.onHover,
    this.imageRendererConfigs = const ImageDisplayConfigsModel(),
  });

  // bool _hovering = false;

  bool get isImage =>
      FileUtils.detectFileTypeFromMimeType(mimeType) == MediaObjectType.image;

  bool get isVideo =>
      FileUtils.detectFileTypeFromMimeType(mimeType) == MediaObjectType.video;

  // FetchSourceData get fetchSourceData => fetchSourceData;

  // ImageDisplayConfigsModel get imageRendererConfigs =>
  //     imageRendererConfigs;

  Widget _handleBuildMediaError(BuildContext context, Object error,
      StackTrace? stackTrace, MediaObjectType mediaType) {
    final Logger _logger = getIt<Logger>();
    _logger.e(
        "mimetype: $mimeType\tmediaType: $mediaType\tfetchSourceMethod: ${fetchSourceData.fetchSourceMethod.stringValue}\nError loading ${mediaType.stringValue} item in 'MediaItemContainer': ${error.toString()}",
        error: error,
        stackTrace: stackTrace);

    return Center(
      child: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
            ),
            Text(
              'Error loading ${mediaType.stringValue}: ${error.toString()}',
              softWrap: true,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedia(BuildContext context) {
    switch (FileUtils.detectFileTypeFromMimeType(mimeType)) {
      case MediaObjectType.image:
        return _buildImage();
      case MediaObjectType.video:
        return _buildVideo(context);
      default:
        return const Center(
          child: Icon(
            Icons.insert_drive_file_rounded,
            size: 46,
            color: Colors.blueGrey,
          ),
        );
    }
  }

  Widget _buildImage() {
    return ImageRenderer(
      fetchSourceData: fetchSourceData,
      imageRendererConfigs: imageRendererConfigs.errorBuilder == null
          ? imageRendererConfigs.copyWith(
              errorBuilder: (context, error, stackTrace) =>
                  _handleBuildMediaError(
                    context,
                    error,
                    stackTrace,
                    MediaObjectType.image,
                  ))
          : imageRendererConfigs,
    );
  }

  Widget _buildVideo(BuildContext context) {
    return _handleBuildMediaError(context, "Video is not yet supported",
        StackTrace.current, MediaObjectType.video);
  }

  @override
  Widget build(BuildContext context) {
    final mediaContent = AspectRatio(
      aspectRatio: mediaRatio ?? 4 / 3,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          ClipRRect(
            borderRadius: shape == BoxShape.circle
                ? BorderRadius.circular(999)
                : BorderRadius.zero,
            child: _buildMedia(context),
          ),
          if (showActionWidget && actionWidget != null)
            Align(
              alignment: actionWidgetPlace,
              child: GestureDetector(
                onTap: onActionWidgetTriggered,
                child: Padding(
                  padding: UiConsts.PaddingAll_standard,
                  child: actionWidget,
                ),
              ),
            ),
        ],
      ),
    );

    final descriptionContent = Container(
      padding: UiConsts.PaddingAll_small,
      width: double.infinity,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: (!showDescriptionBar)
          ? const SizedBox.shrink()
          : Text(
              extraMapData?['description'] ?? 'No description',
              maxLines: descriptionTxtMaxLines,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              textAlign: TextAlign.center,
              // style: const TextStyle(fontSize: 14),
            ),
    );

    final content = Column(
      children: [
        Expanded(flex: mediaAndDescriptionBarFlexValue.$1, child: mediaContent),
        if (showDescriptionBar)
          Expanded(
              flex: mediaAndDescriptionBarFlexValue.$2,
              child: descriptionContent),
      ],
    );

    final decoratedContainer = GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          shape: shape,
          borderRadius: shape == BoxShape.rectangle
              ? UiConsts.BorderRadiusCircular_mediumLarge
              : null,
          border: !showWidgetBorder
              ? null
              : (widgetBorder == null)
                  ? Border.all(color: Colors.grey.shade300)
                  : widgetBorder,
          // boxShadow: _hovering
          //     ? [
          //         BoxShadow(
          //             color: Colors.black54,
          //             blurRadius: 8,
          //             offset: const Offset(0, 4))
          //       ]
          //     : [],
        ),
        clipBehavior: Clip.hardEdge,
        child: content,
      ),
    );

    final gestures = GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      child: decoratedContainer,
    );

    // final mouseRegion = MouseRegion(
    //   cursor: SystemMouseCursors.click,
    //   onEnter: (_) => setState(() => _hovering = true),
    //   onExit: (_) => setState(() => _hovering = false),
    //   onHover: (PointerHoverEvent event) {
    //     widget.onHover?.call(event);
    //   },
    //   child: gestures,
    // );
    if (height == null && width == null) {
      return AspectRatio(
        aspectRatio: widgetRatio,
        child: gestures,
      );
    }

    return gestures;
  }
}

/// Simple wrapper for video player
/// TODO: enhance with controls and other features, and make service class & reusable
class _VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  const _VideoPlayerWidget({required this.videoUrl});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() => _initialized = true);
        _controller.setLooping(true);
        _controller.setVolume(0);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return VideoPlayer(_controller);
  }
}
