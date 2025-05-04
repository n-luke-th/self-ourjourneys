/// lib/views/albums/album_details_page.dart
///

import 'package:flutter/material.dart';
import 'package:ourjourneys/components/main_view.dart';
import 'package:ourjourneys/components/media_item_container.dart'
    show MediaItemContainer;
import 'package:ourjourneys/helpers/dependencies_injection.dart';
import 'package:ourjourneys/helpers/utils.dart';
import 'package:ourjourneys/models/db/albums_model.dart';
import 'package:ourjourneys/models/modification_model.dart';
import 'package:ourjourneys/services/auth/acc/auth_wrapper.dart';
import 'package:ourjourneys/services/dialog/dialog_service.dart';
import 'package:ourjourneys/shared/helpers/misc.dart';
import 'package:ourjourneys/shared/views/ui_consts.dart';
import 'package:ourjourneys/views/albums/full_media_view.dart';
import 'package:shimmer/shimmer.dart';

class AlbumDetailsPage extends StatelessWidget {
  final Map<String, dynamic>? album;
  final AuthWrapper _authWrapper = getIt<AuthWrapper>();
  final double shimmerBaseOpacity = 0.5;
  AlbumDetailsPage({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    if (album == null) {
      return mainView(context,
          body: Center(
              child: Padding(
            padding: UiConsts.PaddingAll_large,
            child: Text('Album not found, please try again'),
          )));
    } else {
      if (_authWrapper.uid == "") _authWrapper.refreshUid();
      AlbumsModel albumData = AlbumsModel.fromMap(map: album!, docId: "");
      final (String createdString, String modifiedString) =
          ModificationData.getModificationDataString(
              modData: albumData.modificationData, uid: _authWrapper.uid);
      return mainView(context,
          appBarTitle: albumData.albumName,
          body: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...[
                Padding(
                  padding: UiConsts.PaddingHorizontal_small,
                  child: Text(createdString),
                ),
                Text(modifiedString),
                Padding(
                  padding: UiConsts.PaddingAll_standard,
                  child: const Divider(
                    height: 2,
                  ),
                ),
              ],
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8.0,
                    children: albumData.linkedObjects.map((objectKey) {
                      if (Utils.detectFileTypeFromFilepath(objectKey) ==
                          "image") {
                        return SizedBox(
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: MediaItemContainer(
                            mimeType: "image/",
                            fetchSourceMethod: FetchSourceMethod.online,
                            mediaItem: objectKey,
                            mediaAndDescriptionBarFlexValue: (8, 1),
                            descriptionTxtMaxLines: 1,
                            extraMapData: {
                              "description": objectKey.split("/").last
                            },
                            onLongPress: () {
                              DialogService.showCustomDialog(
                                context,
                                type: DialogType.information,
                                title: "Information",
                                message:
                                    "Media type: ${Utils.detectFileTypeFromFilepath(objectKey)}\nName: ${objectKey.split("/").last}\nObject key: $objectKey",
                              );
                            },
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (b) => FullMediaView(
                                          objectKey: objectKey,
                                          objectType: "image",
                                        ))),
                          ),
                        );
                      } else {
                        return SizedBox(
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: MediaItemContainer(
                            mimeType: "text/",
                            fetchSourceMethod: FetchSourceMethod.online,
                            mediaItem: null,
                            extraMapData: {"description": objectKey},
                          ),
                        );
                      }
                    }).toList(),
                  ),
                ),
              )
            ],
          )));
    }
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.withOpacity(shimmerBaseOpacity),
      highlightColor: Colors.white.withOpacity(shimmerBaseOpacity),
      child: Container(
        color: Colors.grey[300],
      ),
    );
  }
}
