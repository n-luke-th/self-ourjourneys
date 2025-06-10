/// lib/views/albums/full_media_view.dart
///
// TODO: add ability to fetch the object data from server and display

import 'package:extended_image/extended_image.dart' show ExtendedImageMode;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:ourjourneys/components/main_view.dart';
import 'package:ourjourneys/components/media_item_container.dart'
    show MediaItemContainer;
import 'package:ourjourneys/helpers/utils.dart' show FileUtils;
import 'package:ourjourneys/models/storage/objects_data.dart'
    show MediaObjectType;
import 'package:ourjourneys/shared/helpers/misc.dart' show FetchSourceMethod;
import 'package:ourjourneys/shared/views/ui_consts.dart' show UiConsts;

/// display a full screen media file (image, video, audio, etc)
///
/// which behind the scenes, using the [MediaItemContainer] component
class FullMediaView extends StatelessWidget {
  final String? onlineObjectKey;
  final XFile? localFile;
  final MediaObjectType objectType;
  final Map<String, dynamic>? extraMapData;
  final FetchSourceMethod fetchSourceMethod;
  final bool cloudImageAllowCache;
  final ExtendedImageMode displayImageMode;
  final bool allowShare;
  FullMediaView(
      {super.key,
      this.onlineObjectKey,
      this.localFile,
      required this.objectType,
      this.extraMapData,
      required this.fetchSourceMethod,
      this.cloudImageAllowCache = false,
      this.displayImageMode = ExtendedImageMode.none,
      this.allowShare = true}) {
    if (onlineObjectKey == null &&
        fetchSourceMethod == FetchSourceMethod.server) {
      throw Exception('FullMediaView: onlineObjectKey is null');
    } else if (localFile == null &&
        fetchSourceMethod == FetchSourceMethod.local) {
      throw Exception('FullMediaView: localFile is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? fileName =
        onlineObjectKey?.split("/").last ?? localFile?.name;
    final String appBarTitle =
        "FULL ${FileUtils.detectFileTypeFromFilepath(fileName ?? "OurJourneys File").stringValue.toUpperCase()} VIEW";

    return mainView(context,
        appBarTitle: appBarTitle,
        backgroundColor: Colors.transparent,
        appbarActions: [
          IconButton(
            icon: const Icon(Icons.edit_document),
            onPressed: () => _onPressedEditMediaFile(),
          ),
          if (allowShare)
            // TODO: implement share feature
            Padding(
              padding: UiConsts.PaddingAll_small,
              child: IconButton.filled(
                  onPressed: () => _onPressShareMediaFile(),
                  icon: const Icon(Icons.share_outlined)),
            ),
        ],
        body: Center(
          child: SingleChildScrollView(
            child: Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.spaceBetween,
              runSpacing: 10,
              children: [
                _mediaView(),
                Padding(
                  padding: UiConsts.PaddingAll_small,
                  child: Text(
                    "Media type:\t\t${objectType.stringValue}\nFile extension:\t\t${fileName!.split(".").last}\nName:\t\t$fileName\nSize:\t\t${_getFileSizeInBytes()} bytes ${_getFileSizeInUnit()}\nInitial origin:\t\t${fetchSourceMethod.stringValue}\n${extraMapData?['objectTags'] ?? ""}",
                    maxLines: 8,
                    softWrap: true,
                    textAlign: TextAlign.start,
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Widget _mediaView() {
    switch (objectType) {
      case MediaObjectType.image:
        return _buildImageView();
      case MediaObjectType.video:
        return const Center(child: Text("Video not supported yet"));
      case MediaObjectType.audio:
        return const Center(child: Text("Audio not supported yet"));
      case MediaObjectType.document:
        return const Center(child: Text("Document not supported yet"));
      case MediaObjectType.unknown:
        return const Center(child: Text("Unknown file type"));
      default:
        return const Center(child: Text("File type not supported yet"));
    }
  }

  String _getFileSizeInBytes() {
    return extraMapData?['fileSizeInBytes'].toString() ?? "Unknown";
  }

  String _getFileSizeInUnit() {
    final String fileSizeUnit =
        FileUtils.formatBytes(extraMapData?['fileSizeInBytes']);
    if (fileSizeUnit != "") {
      return "(~ $fileSizeUnit)";
    } else {
      return "";
    }
  }

  void _onPressedEditMediaFile() {}
  void _onPressShareMediaFile() {}

  MediaItemContainer _buildImageView() {
    return fetchSourceMethod == FetchSourceMethod.server
        ? MediaItemContainer(
            showWidgetBorder: false,
            widgetRatio: 1,
            showDescriptionBar: false,
            fetchSourceMethod: FetchSourceMethod.server,
            displayImageMode: displayImageMode,
            cloudImageAllowCache: cloudImageAllowCache,
            imageFilterQuality: FilterQuality.high,
            fitting: BoxFit.contain,
            mediaItem: onlineObjectKey,
            mimeType:
                FileUtils.detectMimeTypeFromFilepath(onlineObjectKey ?? "") ??
                    "image/*",
          )
        : MediaItemContainer(
            showWidgetBorder: false,
            widgetRatio: 1,
            showDescriptionBar: false,
            displayImageMode: displayImageMode,
            cloudImageAllowCache: cloudImageAllowCache,
            fetchSourceMethod: FetchSourceMethod.local,
            imageFilterQuality: FilterQuality.high,
            fitting: BoxFit.contain,
            mediaItem: localFile,
            mimeType: localFile?.mimeType ??
                FileUtils.detectMimeTypeFromFilepath(localFile?.path ?? "") ??
                "image/*",
          );
  }
}
