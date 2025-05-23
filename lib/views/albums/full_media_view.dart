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
import 'package:ourjourneys/shared/helpers/misc.dart';
import 'package:ourjourneys/shared/views/ui_consts.dart';

class FullMediaView extends StatelessWidget {
  final String? onlineObjectKey;
  final PlatformFile? localFile;
  final MediaObjectType objectType;
  final Map<String, dynamic>? extraMapData;
  final FetchSourceMethod fetchSourceMethod;
  FullMediaView(
      {super.key,
      this.onlineObjectKey,
      this.localFile,
      required this.objectType,
      this.extraMapData,
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
        "FULL ${Utils.detectFileTypeFromFilepath(fileName ?? "OurJourneys.jpg").stringValue.toUpperCase()} VIEW";
    if (objectType == MediaObjectType.image) {
      return mainView(context,
          appBarTitle: appBarTitle,
          backgroundColor: Colors.transparent,
          body: Center(
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.spaceBetween,
                runSpacing: 10,
                children: [
                  _buildImageView(),
                  Padding(
                    padding: UiConsts.PaddingAll_small,
                    child: Text(
                      "Media type:\t\t${objectType.stringValue}\nName:\t\t$fileName\nSize:\t\t${localFile?.size ?? extraMapData?['fileSize'] ?? "-"} bytes\nInitial Origin:\t\t${fetchSourceMethod.stringValue}\n${extraMapData?['description'] ?? ""}",
                      maxLines: 8,
                      softWrap: true,
                      textAlign: TextAlign.start,
                    ),
                  )
                ],
              ),
            ),
          ));
    } else if (objectType == MediaObjectType.video) {
      return mainView(context,
          appBarTitle: appBarTitle,
          backgroundColor: Colors.transparent,
          body: const Center(
            child: Text('Video not supported yet'),
          ));
    } else {
      return mainView(context,
          appBarTitle: appBarTitle,
          backgroundColor: Colors.transparent,
          body: Center(
            child: Text("File type '$objectType' not supported yet"),
          ));
    }
  }

  MediaItemContainer _buildImageView() {
    return fetchSourceMethod == FetchSourceMethod.server
        ? MediaItemContainer(
            widgetRatio: 1,
            showDescriptionBar: false,
            fetchSourceMethod: FetchSourceMethod.server,
            fitting: BoxFit.contain,
            mediaItem: onlineObjectKey,
            mimeType: "image/*",
          )
        : MediaItemContainer(
            widgetRatio: 1,
            showDescriptionBar: false,
            fetchSourceMethod: FetchSourceMethod.local,
            fitting: BoxFit.contain,
            mediaItem: localFile?.bytes,
            mimeType: "image/*",
          );
  }
}
