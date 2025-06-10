/// lib/views/albums/album_details_page.dart
///

// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart'
    show FieldValue, Timestamp;
import 'package:extended_image/extended_image.dart' show ExtendedImageMode;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart' show Logger;
import 'package:ourjourneys/components/main_view.dart';
import 'package:ourjourneys/components/media_item_container.dart'
    show MediaItemContainer;
import 'package:ourjourneys/components/more_actions_btn.dart';
import 'package:ourjourneys/helpers/dependencies_injection.dart';
import 'package:ourjourneys/helpers/utils.dart' show FileUtils, Utils;
import 'package:ourjourneys/models/db/albums_model.dart';
import 'package:ourjourneys/models/interface/actions_btn_model.dart';
import 'package:ourjourneys/models/modification_model.dart';
import 'package:ourjourneys/models/storage/objects_data.dart'
    show MediaObjectType;
import 'package:ourjourneys/services/auth/acc/auth_wrapper.dart';
import 'package:ourjourneys/services/cloud/cloud_file_service.dart';
import 'package:ourjourneys/services/db/firestore_wrapper.dart';
import 'package:ourjourneys/services/dialog/dialog_service.dart';
import 'package:ourjourneys/shared/helpers/misc.dart';
import 'package:ourjourneys/shared/services/firestore_commons.dart';
import 'package:ourjourneys/shared/views/ui_consts.dart' show UiConsts;
import 'package:ourjourneys/views/albums/full_media_view.dart';

/// a page to display the details of an album and a list of items associate with it
class AlbumDetailsPage extends StatefulWidget {
  final Map<String, dynamic>? album;
  final bool cloudImageAllowCache;

  const AlbumDetailsPage(
      {super.key, required this.album, this.cloudImageAllowCache = true});

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
          appBarTitle: 'Album not found',
          body: Center(
              child: Padding(
            padding: UiConsts.PaddingAll_large,
            child: const Text('Album not found, please try again'),
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
            Padding(
              padding: UiConsts.PaddingAll_standard,
              child: MoreActionsBtn(
                  actions: [
                    if (albumData.linkedObjects.isNotEmpty)
                      ActionsBtnModel(
                          actionName: "Select items",
                          icon: const Icon(
                            Icons.check_circle_outline_outlined,
                          ),
                          onPressed: () => _onTouchedSelectItemsActionBtn()),
                    ActionsBtnModel(
                        actionName: "Delete Album",
                        actionDes: "Delete this album",
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.redAccent,
                        ),
                        onPressed: () async =>
                            await _onTouchedDeleteSingleAlbumActionBtn(
                                albumData))
                  ],
                  displayIcon: const Icon(
                    Icons.menu_outlined,
                  )),
            ),
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
                  padding: UiConsts.PaddingVertical_large,
                  child: Wrap(
                    clipBehavior: Clip.antiAlias,
                    spacing: 16,
                    runSpacing: 8.0,
                    children: albumData.linkedObjects.map((objectKey) {
                      if (FileUtils.detectFileTypeFromFilepath(objectKey) ==
                          MediaObjectType.image) {
                        return SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.4,
                          child: MediaItemContainer(
                            mimeType: "image/",
                            fetchSourceMethod: FetchSourceMethod.server,
                            cloudImageAllowCache: widget.cloudImageAllowCache,
                            imageFilterQuality: FilterQuality.low,
                            mediaItem:
                                Utils.getThumbnailKeyFromObjectKey(objectKey),
                            mediaAndDescriptionBarFlexValue: (8, 1),
                            descriptionTxtMaxLines: 1,
                            extraMapData: {
                              "description": objectKey.split("/").last
                            },
                            showActionWidget: true,
                            actionWidget: IconButton(
                              color: Colors.redAccent,
                              onPressed: () async {
                                await _deleteCurrentItem(objectKey);
                              },
                              icon: const Icon(
                                Icons.delete_forever_outlined,
                              ),
                              // const Icon(
                              //   Icons.more_vert_outlined,
                              // ),
                            ),
                            onLongPress: () async =>
                                await _onLongPressMediaItem(),
                            onDoubleTap: () async =>
                                await _onDoubleTapMediaItem(objectKey),
                            onTap: () => _onTapMediaItem(objectKey),
                          ),
                        );
                      } else {
                        return SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.2,
                          child: MediaItemContainer(
                            mimeType: "text/",
                            fetchSourceMethod: FetchSourceMethod.server,
                            mediaItem: null,
                            extraMapData: {"description": objectKey},
                          ),
                        );
                      }
                    }).toList(),
                  ),
                ),
              ),
            ],
          )));
    }
  }

  Future<dynamic> _onTapMediaItem(String objectKey) {
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (b) => FullMediaView(
                  fetchSourceMethod: FetchSourceMethod.server,
                  onlineObjectKey: objectKey,
                  objectType: MediaObjectType.image,
                  cloudImageAllowCache: true,
                  displayImageMode: ExtendedImageMode.gesture,
                )));
  }

  Future<void> _onDoubleTapMediaItem(String objectKey) async {
    await DialogService.showCustomDialog(
      context,
      type: DialogType.information,
      title: "Information",
      message:
          "Media type: ${FileUtils.detectFileTypeFromFilepath(objectKey).stringValue}\nName: ${objectKey.split("/").last}\nObject key: $objectKey",
    );
  }

  void _onTouchedSelectItemsActionBtn() =>
      _logger.d("select items action pressed");

  Future<void> _onLongPressMediaItem() async {
    // await _deleteCurrentItem(context, objectKey);
    await DialogService.showCustomDialog(context,
        type: DialogType.information,
        title: "Alert",
        message: "You have long pressed the item.");
  }

  Future<void> _deleteCurrentItem(String objectKey) async {
    // TODO: convert to unlink from album action and add dedicated delete file action in the future
    // ! delete from server, files must be in the same folder to delete
    final bool? confirmation = await DialogService.showConfirmationDialog(
        context: context,
        title: "Delete file?",
        message: "Are you sure to delete '${objectKey.split("/").last}'?",
        confirmText: "DELETE");
    if (confirmation == true) {
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

      final String? folder = FileUtils.getFolderPathFromObjectKey(objectKey);
      if (folder != null) {
        await _cloudFileService.deleteObjectsSameFolder(context,
            objectKeys: [objectKey], folder: folder);
      }
    }
  }

  Future<void> _onTouchedDeleteSingleAlbumActionBtn(
      AlbumsModel albumData) async {
    final bool? result = await DialogService.showConfirmationDialog(
      context: context,
      title: 'Delete album',
      message: 'Are you sure you want to delete this album?',
    );
    if (result == true) {
      _logger.i('Deleting album');
      final List<String> objectsDataDocIds = await _firestoreWrapper
          .queryCollection(FirestoreCollections.objectsData, filters: [
            QueryFilter(
                "linkedAlbums", albumData.id, QueryCondition.arrayContains)
          ])
          .get()
          .then((result) => result.docs.map((doc) => doc.id).toList());
      _logger.d("objectsDataDocIds to be edited: $objectsDataDocIds");

      for (String docId in objectsDataDocIds) {
        _logger.d("Editing objectData docId: $docId");
        await _firestoreWrapper.handleUpdateDocument(context,
            collectionName: FirestoreCollections.objectsData,
            docId: docId,
            suppressNotification: true,
            data: {
              "linkedAlbums": FieldValue.arrayRemove([albumData.id])
            });
      }

      await _firestoreWrapper.handleDeleteDocument(
          context, FirestoreCollections.albums, albumData.id,
          suppressNotification: true);
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
      return;
    }
  }
}
