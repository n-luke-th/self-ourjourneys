/// lib/views/albums/album_details_page.dart
///

// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:ourjourneys/components/main_view.dart';
import 'package:ourjourneys/components/media_item_container.dart'
    show MediaItemContainer;
import 'package:ourjourneys/helpers/dependencies_injection.dart';
import 'package:ourjourneys/helpers/utils.dart';
import 'package:ourjourneys/models/db/albums_model.dart';
import 'package:ourjourneys/models/modification_model.dart';
import 'package:ourjourneys/services/auth/acc/auth_wrapper.dart';
import 'package:ourjourneys/services/cloud/cloud_file_service.dart';
import 'package:ourjourneys/services/db/firestore_wrapper.dart';
import 'package:ourjourneys/services/dialog/dialog_service.dart';
import 'package:ourjourneys/shared/helpers/misc.dart';
import 'package:ourjourneys/shared/services/firestore_commons.dart';
import 'package:ourjourneys/shared/views/ui_consts.dart';
import 'package:ourjourneys/views/albums/full_media_view.dart';
import 'package:shimmer/shimmer.dart';

class AlbumDetailsPage extends StatefulWidget {
  final Map<String, dynamic>? album;

  const AlbumDetailsPage({super.key, required this.album});

  @override
  State<AlbumDetailsPage> createState() => _AlbumDetailsPageState();
}

class _AlbumDetailsPageState extends State<AlbumDetailsPage> {
  final AuthWrapper _authWrapper = getIt<AuthWrapper>();
  final CloudFileService _cloudFileService = getIt<CloudFileService>();
  final FirestoreWrapper _firestoreWrapper = getIt<FirestoreWrapper>();
  final Logger _logger = getIt<Logger>();
  final double shimmerBaseOpacity = 0.5;

  late Map<String, dynamic>? album;

  @override
  void initState() {
    super.initState();
    album = widget.album;
  }

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
      AlbumsModel albumData =
          AlbumsModel.fromMap(map: album!, docId: album!['id'] ?? "");
      final (String createdString, String modifiedString) =
          ModificationData.getModificationDataString(
              modData: albumData.modificationData, uid: _authWrapper.uid);
      return mainView(context,
          appBarTitle: albumData.albumName,
          appbarActions: [
            IconButton(
                onPressed: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: const Text('Delete album'),
                          content: const Text(
                              'Are you sure you want to delete this album?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel')),
                            TextButton(
                                onPressed: () async {
                                  // await _firestoreWrapper.deleteAlbum(
                                  //     albumData.albumId);
                                  Navigator.pop(context);
                                },
                                child: const Text('Delete')),
                          ],
                        )),
                icon: const Icon(Icons.delete)),
          ],
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
                            showActionWidget: true,
                            actionWidget: IconButton(
                              color: Colors.redAccent,
                              onPressed: () async {
                                await _deleteCurrentItem(context, objectKey);
                              },
                              icon: const Icon(
                                Icons.delete_forever_outlined,
                              ),
                              // const Icon(
                              //   Icons.more_vert_outlined,
                              // ),
                            ),
                            onLongPress: () async {
                              // await _deleteCurrentItem(context, objectKey);
                              await DialogService.showCustomDialog(context,
                                  type: DialogType.information,
                                  title: "Alert",
                                  message: "You have long pressed the item.");
                            },
                            onDoubleTap: () async {
                              await DialogService.showCustomDialog(
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

  Future<void> _deleteCurrentItem(
      BuildContext context, String objectKey) async {
    // TODO: add machanism to: 1. just remove file from album 2. delete file from server
    // ! delete from server, files must be in the same folder to delete
    final bool? confirmation = await DialogService.showConfirmationDialog(
        context: context,
        title: "Delete file?",
        message: "Are you sure to delete '${objectKey.split("/").last}'?",
        confirmText: "DELETE");
    if (confirmation == true) {
      // TODO: also remove the reference from the album first before deleting the file
      if (_authWrapper.uid == "") _authWrapper.refreshUid();
      if (album is Map<String, dynamic>) {
        final Timestamp now = Timestamp.now();
        final originalAlbumData =
            AlbumsModel.fromMap(map: album!, docId: album!["id"]);
        final ModificationData modificationData =
            ModificationData.fromMap(album!["modificationData"]).copyWith(
                lastModifiedAt: now, lastModifiedByUserId: _authWrapper.uid);
        final AlbumsModel updatedAlbumData = originalAlbumData.copyWith(
          id: album!["id"],
          modificationData: modificationData,
          linkedObjects: originalAlbumData.linkedObjects
              .where((obj) => obj != objectKey)
              .toList(),
        );
        _logger.d("updatedAlbumData: ${updatedAlbumData.toMap()}");
        setState(() {
          album = updatedAlbumData.toMap();
        });
        await _firestoreWrapper.handleUpdateDocument(context,
            collectionName: FirestoreCollections.albums,
            data: updatedAlbumData.toMap(),
            docId: updatedAlbumData.id,
            suppressNotification: true);
      }

      final String? folder = Utils.getFolderPathFromObjectKey(objectKey);
      if (folder != null) {
        await _cloudFileService.deleteObjectsSameFolder(context,
            objectKeys: [objectKey], folder: folder);
      }
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
