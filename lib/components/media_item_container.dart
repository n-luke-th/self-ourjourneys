/// lib/components/media_item_container.dart
///

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PointerHoverEvent;
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
class MediaItemContainer extends StatefulWidget {
  final String mimeType;

  /// tells how to fetch the media from, also included all the necessary data to fetch the media from the source
  final FetchSourceData fetchSourceData;

  final bool showActionWidget;
  final Widget? actionWidget;
  final ActionWidgetPlace actionWidgetPlace;
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
  final void Function(PointerHoverEvent)? onHover;

  /// the configs for the image to be displayed
  final ImageDisplayConfigsModel imageRendererConfigs;

  const MediaItemContainer({
    super.key,
    required this.mimeType,
    required this.fetchSourceData,
    this.showActionWidget = false,
    this.actionWidget,
    this.actionWidgetPlace = ActionWidgetPlace.topRight,
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
    this.onHover,
    this.imageRendererConfigs = const ImageDisplayConfigsModel(),
  });

  @override
  State<MediaItemContainer> createState() => _MediaItemContainerState();
}

class _MediaItemContainerState extends State<MediaItemContainer> {
  final Logger _logger = getIt<Logger>();
  bool _hovering = false;
  bool get isImage =>
      FileUtils.detectFileTypeFromMimeType(widget.mimeType) ==
      MediaObjectType.image;
  bool get isVideo =>
      FileUtils.detectFileTypeFromMimeType(widget.mimeType) ==
      MediaObjectType.video;

  FetchSourceData get fetchSourceData => widget.fetchSourceData;

  ImageDisplayConfigsModel get imageRendererConfigs =>
      widget.imageRendererConfigs;

  Widget _handleBuildMediaError(BuildContext context, Object error,
      StackTrace? stackTrace, MediaObjectType mediaType) {
    _logger.d(
        "mimetype: ${widget.mimeType}\tmediaType: $mediaType\tfetchSourceMethod: ${widget.fetchSourceData.fetchSourceMethod.stringValue}");
    _logger.e(
        "Error loading ${mediaType.stringValue} item in 'MediaItemContainer': ${error.toString()}",
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

  Widget _buildMedia() {
    switch (FileUtils.detectFileTypeFromMimeType(widget.mimeType)) {
      case MediaObjectType.image:
        return _buildImage();
      case MediaObjectType.video:
        return _buildVideo();
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
      imageRendererConfigs: imageRendererConfigs,
    );
  }

  Widget _buildVideo() {
    return _handleBuildMediaError(context, "Video is not yet supported",
        StackTrace.current, MediaObjectType.video);
  }

  Alignment _getAlignment(ActionWidgetPlace place) {
    switch (place) {
      case ActionWidgetPlace.topRight:
        return Alignment.topRight;
      case ActionWidgetPlace.top:
        return Alignment.topCenter;
      case ActionWidgetPlace.topLeft:
        return Alignment.topLeft;
      case ActionWidgetPlace.bottomRight:
        return Alignment.bottomRight;
      case ActionWidgetPlace.bottom:
        return Alignment.bottomCenter;
      case ActionWidgetPlace.bottomLeft:
        return Alignment.bottomLeft;
      case ActionWidgetPlace.centerRight:
        return Alignment.centerRight;
      case ActionWidgetPlace.centerLeft:
        return Alignment.centerLeft;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaContent = AspectRatio(
      aspectRatio: widget.mediaRatio ?? 4 / 3,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          ClipRRect(
            borderRadius: widget.shape == BoxShape.circle
                ? BorderRadius.circular(999)
                : BorderRadius.zero,
            child: _buildMedia(),
          ),
          if (widget.showActionWidget && widget.actionWidget != null)
            Align(
              alignment: _getAlignment(widget.actionWidgetPlace),
              child: GestureDetector(
                onTap: widget.onActionWidgetTriggered,
                child: Padding(
                  padding: UiConsts.PaddingAll_standard,
                  child: widget.actionWidget,
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
      child: (!widget.showDescriptionBar)
          ? const SizedBox.shrink()
          : Text(
              widget.extraMapData?['description'] ?? 'No description',
              maxLines: widget.descriptionTxtMaxLines,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              textAlign: TextAlign.center,
              // style: const TextStyle(fontSize: 14),
            ),
    );

    final content = Column(
      children: [
        Expanded(
            flex: widget.mediaAndDescriptionBarFlexValue.$1,
            child: mediaContent),
        if (widget.showDescriptionBar)
          Expanded(
              flex: widget.mediaAndDescriptionBarFlexValue.$2,
              child: descriptionContent),
      ],
    );

    final decoratedContainer = GestureDetector(
      onTap: widget.onTap,
      onDoubleTap: widget.onDoubleTap,
      onLongPress: widget.onLongPress,
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          shape: widget.shape,
          borderRadius: widget.shape == BoxShape.rectangle
              ? UiConsts.BorderRadiusCircular_mediumLarge
              : null,
          border: !widget.showWidgetBorder
              ? null
              : (widget.widgetBorder == null)
                  ? Border.all(color: Colors.grey.shade300)
                  : widget.widgetBorder,
          boxShadow: _hovering
              ? [
                  BoxShadow(
                      color: Colors.black54,
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        clipBehavior: Clip.hardEdge,
        child: content,
      ),
    );

    final gestures = GestureDetector(
      onTap: widget.onTap,
      onDoubleTap: widget.onDoubleTap,
      onLongPress: widget.onLongPress,
      child: decoratedContainer,
    );

    final mouseRegion = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      onHover: (PointerHoverEvent event) {
        widget.onHover?.call(event);
      },
      child: gestures,
    );
    if (widget.height == null && widget.width == null) {
      return AspectRatio(
        aspectRatio: widget.widgetRatio,
        child: mouseRegion,
      );
    }

    return mouseRegion;
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
