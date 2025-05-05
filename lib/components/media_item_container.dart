/// lib/components/media_item_container.dart
///
/// media item container

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PointerHoverEvent;
import 'package:ourjourneys/components/cloud_image.dart';
import 'package:ourjourneys/shared/helpers/misc.dart' show FetchSourceMethod;
import 'package:ourjourneys/shared/views/ui_consts.dart';
import 'package:video_player/video_player.dart';

class MediaItemContainer extends StatefulWidget {
  final String mimeType;
  final FetchSourceMethod fetchSourceMethod;
  final dynamic
      mediaItem; // URL (String) or Bytes (Uint8List) or ObjectKey (String)
  final bool showActionWidget;
  final Widget? actionWidget;
  final ActionWidgetPlace actionWidgetPlace;
  final VoidCallback? onActionWidgetTriggered;
  final double widgetRatio;
  final double? height;
  final double? width;
  final double? mediaRatio;
  final BoxFit fitting;
  final BoxShape shape;
  final bool showDescriptionBar;
  final int descriptionTxtMaxLines;
  final (int, int) mediaAndDescriptionBarFlexValue;
  final Map<String, dynamic>? extraMapData;

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
    this.shape = BoxShape.rectangle,
    this.showDescriptionBar = true,
    this.descriptionTxtMaxLines = 3,
    this.mediaAndDescriptionBarFlexValue = (3, 1),
    this.extraMapData,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onHover,
  });

  @override
  State<MediaItemContainer> createState() => _MediaItemContainerState();
}

class _MediaItemContainerState extends State<MediaItemContainer> {
  bool _hovering = false;
  bool get isImage => widget.mimeType.startsWith('image/');
  bool get isVideo => widget.mimeType.startsWith('video/');

  Widget _buildMedia(BuildContext context) {
    if (isImage) {
      if (widget.fetchSourceMethod == FetchSourceMethod.local &&
          widget.mediaItem is Uint8List) {
        return Image.memory(widget.mediaItem,
            fit: widget.fitting,
            width: double.infinity,
            height: double.infinity);
      } else if (widget.fetchSourceMethod == FetchSourceMethod.online &&
          widget.mediaItem is String) {
        return CloudImage(
            objectKey: widget.mediaItem,
            fit: widget.fitting,
            width: double.infinity,
            height: double.infinity);
      }
    }

    if (isVideo &&
        widget.mediaItem is String &&
        widget.fetchSourceMethod == FetchSourceMethod.online) {
      return _VideoPlayerWidget(videoUrl: widget.mediaItem);
    }

    return Center(
        child: Icon(Icons.insert_drive_file, size: 48, color: Colors.grey));
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
            child: _buildMedia(context),
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
      padding: UiConsts.PaddingAll_standard,
      width: double.infinity,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: (!widget.showDescriptionBar)
          ? const SizedBox.shrink()
          : Text(
              widget.extraMapData?['description'] ?? 'No description',
              maxLines: widget.descriptionTxtMaxLines,
              overflow: TextOverflow.ellipsis,
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
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: _hovering
              ? [
                  BoxShadow(
                      color: Colors.black54,
                      blurRadius: 8,
                      offset: Offset(0, 4))
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
