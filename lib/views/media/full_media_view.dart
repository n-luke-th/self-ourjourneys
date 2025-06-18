/// lib/views/media/full_media_view.dart
///
// TODO: add ability to fetch the object data from server and display

import 'package:flutter/material.dart';
import 'package:ourjourneys/components/main_view.dart';
import 'package:ourjourneys/components/media_item_container.dart'
    show MediaItemContainer;
import 'package:ourjourneys/helpers/utils.dart' show FileUtils;
import 'package:ourjourneys/models/interface/image_display_configs_model.dart';
import 'package:ourjourneys/models/storage/fetch_source_data.dart';
import 'package:ourjourneys/models/storage/objects_data.dart'
    show MediaObjectType;
import 'package:ourjourneys/shared/views/ui_consts.dart' show UiConsts;

/// display a full screen media file (image, video, audio, etc)
///
/// which behind the scenes, using the [MediaItemContainer] component
class FullMediaView extends StatelessWidget {
  final FetchSourceData fetchSourceData;
  final MediaObjectType objectType;
  final bool allowShare;
  final Map<String, dynamic>? extraMapData;
  final ImageDisplayConfigsModel? imageRendererConfigs;
  FullMediaView({
    super.key,
    required this.fetchSourceData,
    required this.objectType,
    this.allowShare = true,
    this.extraMapData,
    this.imageRendererConfigs,
  }) {
    switch (objectType) {
      case MediaObjectType.image:
        assert(imageRendererConfigs != null);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? fileName =
        fetchSourceData.cloudFileObjectKey?.split("/").last ??
            fetchSourceData.localFile?.name;
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
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 10,
              children: [
                _mediaView(),
                Padding(
                  padding: UiConsts.PaddingAll_small,
                  child: Text(
                    "Media type:\t\t${objectType.stringValue}\nFile extension:\t\t${fileName!.split(".").last}\nName:\t\t$fileName\nSize:\t\t${_getFileSizeInBytes()} bytes ${_getFileSizeInUnit()}\nInitial origin:\t\t${fetchSourceData.fetchSourceMethod.stringValue}\n${extraMapData?['objectTags'] ?? ""}",
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
    return MediaItemContainer(
      fetchSourceData: fetchSourceData,
      mimeType: fetchSourceData.localFile?.mimeType ??
          FileUtils.detectMimeTypeFromFilepath(
              fetchSourceData.cloudFileObjectKey ??
                  fetchSourceData.localFile?.path ??
                  "") ??
          "image/*",
      imageRendererConfigs: imageRendererConfigs!,
      showWidgetBorder: false,
      widgetRatio: 1,
      showDescriptionBar: false,
    );
  }
}
