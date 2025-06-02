/// lib/components/media_item_container.dart
///

import 'dart:typed_data' show Uint8List;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PointerHoverEvent;
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:logger/logger.dart';
import 'package:ourjourneys/helpers/dependencies_injection.dart';
import 'package:ourjourneys/helpers/get_platform_service.dart';
import 'package:ourjourneys/helpers/utils.dart';
import 'package:ourjourneys/models/storage/objects_data.dart'
    show MediaObjectType;
import 'package:universal_io/io.dart' show File;
import 'package:video_player/video_player.dart';

import 'package:ourjourneys/components/cloud_image.dart';
import 'package:ourjourneys/shared/helpers/misc.dart' show FetchSourceMethod;
import 'package:ourjourneys/shared/views/ui_consts.dart';

/// media item container
///
/// component for displaying media items (images, videos, etc.)
/// - for images, if local file using [Image.file] or if a cloud object using [CloudImage]
class MediaItemContainer extends StatefulWidget {
  final String mimeType;
  final FetchSourceMethod fetchSourceMethod;

  /// Video: URL (String) | Image: ObjectKey (String) or XFile or Bytes (Uint8List)
  final dynamic mediaItem;
  final bool showActionWidget;
  final Widget? actionWidget;
  final ActionWidgetPlace actionWidgetPlace;
  final VoidCallback? onActionWidgetTriggered;
  final double widgetRatio;
  final double? height;
  final double? width;
  final double? mediaRatio;
  final BoxFit fitting;
  final FilterQuality imageFilterQuality;
  final BoxShape shape;
  final bool showDescriptionBar;
  final int descriptionTxtMaxLines;
  final (int, int) mediaAndDescriptionBarFlexValue;
  final Map<String, dynamic>? extraMapData;
  final bool showWidgetBorder;
  final BoxBorder? widgetBorder;

  /// if true and mediaItem is a String, CloudImage will be used to fetch the image with caching allowed
  final bool cloudImageAllowCache;

  // gesture callbacks
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final void Function(PointerHoverEvent)? onHover;

  const MediaItemContainer({
    super.key,
    required this.mimeType,
    required this.fetchSourceMethod,
    required this.mediaItem,
    this.showActionWidget = false,
    this.actionWidget,
    this.actionWidgetPlace = ActionWidgetPlace.topRight,
    this.onActionWidgetTriggered,
    this.widgetRatio = 10 / 16,
    this.height,
    this.width,
    this.mediaRatio,
    this.fitting = BoxFit.cover,
    this.imageFilterQuality = FilterQuality.medium,
    this.shape = BoxShape.rectangle,
    this.showDescriptionBar = true,
    this.descriptionTxtMaxLines = 3,
    this.mediaAndDescriptionBarFlexValue = (3, 1),
    this.extraMapData,
    this.showWidgetBorder = true,
    this.widgetBorder,
    this.cloudImageAllowCache = true,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onHover,
  });

  @override
  State<MediaItemContainer> createState() => _MediaItemContainerState();
}

class _MediaItemContainerState extends State<MediaItemContainer> {
  final Logger _logger = getIt<Logger>();
  bool _hovering = false;
  bool get isImage =>
      Utils.detectFileTypeFromMimeType(widget.mimeType) ==
      MediaObjectType.image;
  bool get isVideo =>
      Utils.detectFileTypeFromMimeType(widget.mimeType) ==
      MediaObjectType.video;
  // bool get isImage => widget.mimeType.startsWith('image/');
  // bool get isVideo => widget.mimeType.startsWith('video/');

  Widget _handleBuildMediaError(BuildContext context, Object error,
      StackTrace? stackTrace, MediaObjectType mediaType) {
    _logger.d(
        "mimetype: ${widget.mimeType}\tmediaType: $mediaType\tfetchSourceMethod: ${widget.fetchSourceMethod.stringValue}\tmediaItem: ${widget.mediaItem.runtimeType}");
    _logger.e(
        "Error loading ${mediaType.stringValue} item in 'MediaItemContainer': ${error.toString()}",
        error: error,
        stackTrace: stackTrace);

    return Center(
      child: SizedBox(
        child: Wrap(
          direction: Axis.vertical,
          alignment: WrapAlignment.spaceEvenly,
          runAlignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 8,
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
    if (isImage) {
      if (widget.fetchSourceMethod == FetchSourceMethod.local &&
          widget.mediaItem is Uint8List) {
        // local image using bytes.
        return _buildMemoryImage();
      } else if (widget.fetchSourceMethod == FetchSourceMethod.local &&
          widget.mediaItem is XFile) {
        // local image using XFile
        if (PlatformDetectionService.isWeb && widget.mediaItem.path.isEmpty) {
          // can not handle path, need pure Uint8List (bytes)
          return _buildMemoryImage();
        } else if (PlatformDetectionService.isMobile &&
            widget.mediaItem.path.isNotEmpty) {
          // can handle path, use Image.file
          _logger.d("using Image.file");
          return Image.file(
            File(widget.mediaItem.path),
            fit: widget.fitting,
            width: double.infinity,
            height: double.infinity,
            filterQuality: widget.imageFilterQuality,
            errorBuilder: (context, error, stackTrace) =>
                _handleBuildMediaError(
                    context, error, stackTrace, MediaObjectType.image),
          );
        } else {
          // fallback to Uint8List (bytes)
          return _buildMemoryImage();
        }
      } else if (widget.fetchSourceMethod == FetchSourceMethod.server &&
          widget.mediaItem is String) {
        // server image using objectKey
        return CloudImage(
          objectKey: widget.mediaItem,
          fit: widget.fitting,
          width: double.infinity,
          height: double.infinity,
          filterQuality: widget.imageFilterQuality,
          allowCache: widget.cloudImageAllowCache,
          errorBuilder: (context, error, stackTrace) => _handleBuildMediaError(
              context, error, stackTrace, MediaObjectType.image),
        );
      } else {
        // fallback to error
        return _handleBuildMediaError(
            context, 'Unknown error', null, MediaObjectType.image);
      }
    }

    if (isVideo &&
        widget.mediaItem is String &&
        widget.fetchSourceMethod == FetchSourceMethod.server) {
      return _VideoPlayerWidget(videoUrl: widget.mediaItem);
    }

    return const Center(
        child: Icon(Icons.insert_drive_file, size: 48, color: Colors.grey));
  }

  /// render image using bytes by loading the entire image file into memory.
  /// significant performance consumption, avoid using.
  Widget _buildMemoryImage() {
    _logger.d("using Image.memory");
    if (widget.mediaItem is Uint8List) {
      return Image.memory(
        widget.mediaItem,
        fit: widget.fitting,
        width: double.infinity,
        height: double.infinity,
        filterQuality: widget.imageFilterQuality,
        errorBuilder: (context, error, stackTrace) => _handleBuildMediaError(
            context, error, stackTrace, MediaObjectType.image),
      );
    } else {
      return FutureBuilder<Uint8List>(
          future: widget.mediaItem.readAsBytes(),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState == ConnectionState.done) {
              return Image.memory(
                asyncSnapshot.data ?? Uint8List(0),
                fit: widget.fitting,
                width: double.infinity,
                height: double.infinity,
                colorBlendMode: BlendMode.clear,
                filterQuality: widget.imageFilterQuality,
                errorBuilder: (context, error, stackTrace) =>
                    _handleBuildMediaError(
                        context, error, stackTrace, MediaObjectType.image),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          });
    }
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
              ? UiConsts.BorderRadiusCircular_standard
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
