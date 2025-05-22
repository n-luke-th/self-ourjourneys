/// lib/views/albums/full_media_view.dart
///
/// display a full screen media file (image, video, audio, etc)

import 'package:flutter/material.dart';
import 'package:ourjourneys/components/main_view.dart';
import 'package:ourjourneys/components/media_item_container.dart'
    show MediaItemContainer;
import 'package:ourjourneys/shared/helpers/misc.dart';

class FullMediaView extends StatelessWidget {
  final String objectKey;
  final String objectType;
  const FullMediaView(
      {super.key, required this.objectKey, required this.objectType});

  @override
  Widget build(BuildContext context) {
    if (objectType == "image") {
      return mainView(context,
          appBarTitle: objectKey.split('/').last,
          backgroundColor: Colors.transparent,
          body: Center(
            // child: CloudImage(objectKey: objectKey),
            child: MediaItemContainer(
              showDescriptionBar: false,
              fetchSourceMethod: FetchSourceMethod.online,
              fitting: BoxFit.contain,
              mediaItem: objectKey,
              mimeType: "image/",
            ),
          ));
    } else if (objectType == "video") {
      return mainView(context,
          appBarTitle: objectKey.split('/').last,
          body: const Center(
            child: Text('Video not supported yet'),
          ));
    } else {
      return mainView(context,
          appBarTitle: objectKey.split('/').last,
          body: Center(
            child: Text("File type '$objectType' not supported yet"),
          ));
    }
  }
}
