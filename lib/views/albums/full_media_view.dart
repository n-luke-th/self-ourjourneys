/// lib/views/albums/full_media_view.dart
///
/// display a full screen media file (image, video, audio, etc)

import 'package:file_picker/file_picker.dart' show PlatformFile;
import 'package:flutter/material.dart';
import 'package:ourjourneys/components/main_view.dart';
import 'package:ourjourneys/components/media_item_container.dart'
    show MediaItemContainer;
import 'package:ourjourneys/helpers/utils.dart' show Utils;
import 'package:ourjourneys/models/storage/objects_data.dart'
    show MediaObjectType;
import 'package:ourjourneys/shared/helpers/misc.dart' show FetchSourceMethod;
import 'package:ourjourneys/shared/views/ui_consts.dart' show UiConsts;

class FullMediaView extends StatelessWidget {
  final String? onlineObjectKey;
  final PlatformFile? localFile;
  final MediaObjectType objectType;
  final Map<String, dynamic>? extraMapData;
  final FetchSourceMethod fetchSourceMethod;
  final bool cloudImageAllowCache;
  FullMediaView(
      {super.key,
      this.onlineObjectKey,
      this.localFile,
      required this.objectType,
      this.extraMapData,
      this.cloudImageAllowCache = false,
      required this.fetchSourceMethod}) {
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
        "FULL ${Utils.detectFileTypeFromFilepath(fileName ?? "OurJourneys File").stringValue.toUpperCase()} VIEW";

    return mainView(context,
        appBarTitle: appBarTitle,
        backgroundColor: Colors.transparent,
        appbarActions: [
          IconButton(
            icon: const Icon(Icons.edit_document),
            onPressed: () => _onPressedEditMediaFile(),
          ),
          Padding(
            padding: UiConsts.PaddingAll_small,
            child: IconButton.filled(
                onPressed: () => _onPressDownloadMediaFile(),
                icon: const Icon(Icons.download_rounded)),
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
                    "Media type:\t\t${objectType.stringValue}\nName:\t\t$fileName\nSize:\t\t${localFile?.size ?? extraMapData?['fileSizeInBytes'] ?? "-"} bytes\nInitial origin:\t\t${fetchSourceMethod.stringValue}\n${extraMapData?['description'] ?? ""}",
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

  void _onPressedEditMediaFile() {}
  void _onPressDownloadMediaFile() {}

  MediaItemContainer _buildImageView() {
    return fetchSourceMethod == FetchSourceMethod.server
        ? MediaItemContainer(
            widgetRatio: 1,
            showDescriptionBar: false,
            fetchSourceMethod: FetchSourceMethod.server,
            cloudImageAllowCache: cloudImageAllowCache,
            fitting: BoxFit.contain,
            mediaItem: onlineObjectKey,
            mimeType: "image/*",
          )
        : MediaItemContainer(
            widgetRatio: 1,
            showDescriptionBar: false,
            cloudImageAllowCache: cloudImageAllowCache,
            fetchSourceMethod: FetchSourceMethod.local,
            fitting: BoxFit.contain,
            mediaItem: localFile?.bytes,
            mimeType: "image/*",
          );
  }
}
