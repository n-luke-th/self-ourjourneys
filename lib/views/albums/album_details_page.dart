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
import 'package:ourjourneys/helpers/dependencies_injection.dart' show getIt;
import 'package:ourjourneys/helpers/utils.dart'
    show FileUtils, InterfaceUtils, Utils;
import 'package:ourjourneys/models/db/albums_model.dart';
import 'package:ourjourneys/models/interface/image_display_configs_model.dart';
import 'package:ourjourneys/models/modification_model.dart';
import 'package:ourjourneys/models/storage/fetch_source_data.dart';
import 'package:ourjourneys/models/storage/objects_data.dart'
    show MediaObjectType;
import 'package:ourjourneys/services/auth/acc/auth_wrapper.dart';
import 'package:ourjourneys/services/cloud/cloud_file_service.dart';
import 'package:ourjourneys/services/db/firestore_wrapper.dart';
import 'package:ourjourneys/services/dialog/dialog_service.dart';
import 'package:ourjourneys/shared/common/page_mode_enum.dart';
import 'package:ourjourneys/shared/helpers/misc.dart';
import 'package:ourjourneys/shared/services/firestore_commons.dart';
import 'package:ourjourneys/shared/views/ui_consts.dart' show UiConsts;
import 'package:ourjourneys/views/media/full_media_view.dart';

/// a page to display the details of an album and a list of items associate with it
class AlbumDetailsPage extends StatefulWidget {
  final AlbumsModel? album;
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
  final ScrollController _scrollController = ScrollController();

  final Set<String> _selectedItems = {};

  late AlbumsModel? albumData;
  late PageMode _mode;

  bool _isActivatedSelectionMode = false;

  bool get _isSelectedAllItems =>
      _currentModeIs(PageMode.edit) &&
      (_selectedItems.length == albumData?.linkedObjects.length);

  bool get _isSelectingItems =>
      _currentModeIs(PageMode.edit) &&
      (_selectedItems.isNotEmpty) &&
      _isActivatedSelectionMode;

  @override
  void initState() {
    super.initState();
    albumData = widget.album;
    _mode = PageMode.view;
  }

  @override
  void dispose() {
    albumData = null;
    _selectedItems.clear();
    _scrollController.dispose();
    super.dispose();
  }

  /// check if the current active mode is the one passed as parameter [toCompareMode]
  bool _currentModeIs(PageMode toCompareMode) {
    return toCompareMode == _mode;
  }

  void _resetToViewMode() {
    _selectedItems.clear();
    _isActivatedSelectionMode = false;
  }

  /// change the current active mode to either of the following:
  /// - [PageMode.view]
  /// - [PageMode.edit]
  void _toggleMode() {
    if (albumData != null) {
      setState(() {
        _mode = _currentModeIs(PageMode.edit) ? PageMode.view : PageMode.edit;
        _currentModeIs(PageMode.view) ? _resetToViewMode() : null;
      });
    }
    _logger.d("mode now is ${_mode.name}");
  }

  bool _isItemSelected(String objectKey) {
    if (_isActivatedSelectionMode && _currentModeIs(PageMode.edit)) {
      return _selectedItems.contains(objectKey);
    } else {
      return false;
    }
  }

  /// build the bottom page widget for the edit mode
  List<Widget> _buildActionsForEditMode() {
    return [
      ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.inverseSurface,
            padding: UiConsts.PaddingAll_standard,
            shape: RoundedSuperellipseBorder(
                borderRadius: UiConsts.BorderRadiusCircular_medium)),
        onPressed: () => _onTouchedSelectItemsActionBtn(),
        child: const Text("Select items"),
      ),
      if (!_isSelectingItems)
        IconButton.filled(
            onPressed: () => _toAddMoreMediaToAlbumPage(),
            tooltip: "Add more media to album",
            enableFeedback: true,
            icon: const Icon(Icons.upload_file_outlined)),
      if (_isSelectingItems)
        IconButton.outlined(
            enableFeedback: true,
            tooltip: "Unlink from album",
            onPressed: () async {
              await _unlinkSelectedItems(_selectedItems.toList());
            },
            icon: const Icon(
              Icons.do_disturb_outlined,
              color: Colors.orange,
            )),
      IconButton.outlined(
          enableFeedback: true,
          tooltip: _isSelectingItems ? "Delete selected items" : "Delete album",
          onPressed: () async =>
              await _onTouchedDeleteSingleAlbumActionBtn(albumData),
          icon: const Icon(
            Icons.delete,
            color: Colors.redAccent,
          ))
    ];
  }

  /// build the bottom page widget for the view mode
  List<Widget> _buildActionsForViewMode() {
    return [
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.inverseSurface),
        label: const Text("To top of the page"),
        iconAlignment: IconAlignment.end,
        onPressed: () => InterfaceUtils.scrollToTop(_scrollController),
        icon: const Icon(
          Icons.keyboard_arrow_up_outlined,
        ),
      ),
      // TextButton.icon(onPressed: () async => await {}, label: label)
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (albumData == null) {
      return mainView(context,
          appBarTitle: 'ALBUM DETAILS',
          body: Center(
              child: Padding(
            padding: UiConsts.PaddingAll_large,
            child: const Text('Album not found, please try again later.',
                style: TextStyle(fontSize: 26)),
          )));
    } else {
      if (_authWrapper.uid == "") _authWrapper.refreshUid();

      final (String createdString, String modifiedString) =
          ModificationData.getModificationDataString(
              modData: albumData!.modificationData,
              uid: _authWrapper.uid,
              combinedIfSame: true);
      return mainView(context,
          appBarTitle: 'ALBUM DETAILS',
          appbarActions: [
            Padding(
              padding: UiConsts.PaddingAll_standard,
              child: IconButton.filled(
                  enableFeedback: true,
                  onPressed: () async => await DialogService.showInfoDialog(
                      context: context,
                      title: "ALBUM METADATA",
                      message:
                          "Contains: ${albumData!.linkedObjects.length.toString()} ${albumData!.linkedObjects.length <= 1 ? 'item' : 'items'}\n${modifiedString.isNotEmpty ? "$createdString\n$modifiedString" : createdString}"),
                  icon: const Icon(Icons.info_outline_rounded)),
            ),
          ],
          showFloatingActionButton: true,
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
          floatingActionButtonIcon: _currentModeIs(PageMode.edit)
              ? Icons.edit
              : Icons.visibility_outlined,
          floatingActionButtonTooltip:
              "Toggle to ${_currentModeIs(PageMode.view) ? 'Edit' : 'View'} mode",
          floatingActionButtonProps: FloatingActionButton(
            onPressed: () {},
            shape: RoundedSuperellipseBorder(
                borderRadius: UiConsts.BorderRadiusCircular_medium),
          ),
          onFloatingActionButtonPressed: () => _toggleMode(),
          bottomSheet: _isActivatedSelectionMode
              ? Padding(
                  padding: UiConsts.PaddingAll_small,
                  child: TextButton.icon(
                    icon: Icon(
                      !_isSelectedAllItems
                          ? Icons.select_all_outlined
                          : Icons.deselect_outlined,
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),
                    style: ElevatedButton.styleFrom(
                        enableFeedback: true,
                        backgroundColor: Colors.transparent,
                        shape: RoundedSuperellipseBorder(
                            borderRadius:
                                UiConsts.BorderRadiusCircular_medium)),
                    label: Text(
                      _isSelectedAllItems ? "Deselect all" : "Select all",
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Theme.of(context).colorScheme.inverseSurface),
                    ),
                    onPressed: () {
                      _selectOrDeselectAllItems();
                    },
                  ),
                )
              : null,
          bottomNavigationBar: Container(
            padding: UiConsts.PaddingAll_small,
            height: MediaQuery.sizeOf(context).height * 0.1,
            decoration: BoxDecoration(
                color: Theme.of(context).unselectedWidgetColor,
                borderRadius: UiConsts.BorderRadiusCircular_standard,
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).unselectedWidgetColor,
                      blurRadius: 16,
                      blurStyle: BlurStyle.outer),
                  BoxShadow(
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                      blurRadius: 16,
                      blurStyle: BlurStyle.outer)
                ]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                    child: Padding(
                  padding: UiConsts.PaddingAll_small,
                  child: Text(
                    Utils.capitalizeFirstLetter(_mode.getIng),
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(color: Theme.of(context).cardColor),
                    softWrap: true,
                    maxLines: 2,
                    textAlign: TextAlign.start,
                  ),
                )),
                if (_currentModeIs(PageMode.edit))
                  ..._buildActionsForEditMode(),
                if (_currentModeIs(PageMode.view))
                  ..._buildActionsForViewMode(),
              ],
            ),
          ),
          body: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 1,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: UiConsts.PaddingHorizontal_small,
                  child: Text(
                    albumData!.albumName,
                    textAlign: TextAlign.center,
                    style: InterfaceUtils.isBigScreen(context)
                        ? Theme.of(context).primaryTextTheme.headlineLarge
                        : Theme.of(context).primaryTextTheme.headlineSmall,
                    softWrap: true,
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              const Divider(
                height: 2,
              ),
              Expanded(
                flex: 19,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: UiConsts.PaddingVertical_large,
                  child: Wrap(
                    clipBehavior: Clip.antiAlias,
                    spacing: 16,
                    runSpacing: 8.0,
                    children: albumData!.linkedObjects.map((objectKey) {
                      switch (FileUtils.detectFileTypeFromFilepath(objectKey)) {
                        case MediaObjectType.image:
                          return _buildImageObject(objectKey);
                        default:
                          return SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.3,
                            child: MediaItemContainer(
                              mimeType: "",
                              fetchSourceData: FetchSourceData(
                                  fetchSourceMethod: FetchSourceMethod.server,
                                  cloudFileObjectKey:
                                      Utils.getThumbnailKeyFromObjectKey(
                                          objectKey)),
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

  Container _buildImageObject(String objectKey) {
    return Container(
        width: MediaQuery.sizeOf(context).width * 0.4,
        foregroundDecoration: _isItemSelected(objectKey)
            ? BoxDecoration(
                borderRadius: UiConsts.BorderRadiusCircular_superLarge,
                color: Theme.of(context)
                    .colorScheme
                    .tertiaryFixedDim
                    .withAlpha(Color.getAlphaFromOpacity(0.4)))
            : null,
        child: MediaItemContainer(
          mimeType: FileUtils.detectMimeTypeFromFilepath(objectKey) ?? "",
          fetchSourceData: FetchSourceData(
              fetchSourceMethod: FetchSourceMethod.server,
              cloudFileObjectKey:
                  Utils.getThumbnailKeyFromObjectKey(objectKey)),
          imageRendererConfigs: ImageDisplayConfigsModel(
              filterQuality: FilterQuality.low,
              allowCache: widget.cloudImageAllowCache,
              width: double.infinity,
              height: double.infinity),
          mediaAndDescriptionBarFlexValue: (8, 1),
          descriptionTxtMaxLines: 1,
          extraMapData: {"description": objectKey.split("/").last},
          onLongPress: () async => await _onLongPressMediaItem(objectKey),
          onDoubleTap: () async => await _onDoubleTapMediaItem(objectKey),
          onTap: () => _onTapMediaItem(objectKey),
          showActionWidget: true,
          actionWidget: _getActionWidgetForMediaItem(objectKey),
          actionWidgetPlace: _isActivatedSelectionMode
              ? Alignment.topCenter
              : Alignment.topRight,
        ));
  }

  Widget _getActionWidgetForMediaItem(String objectKey) {
    return !_isActivatedSelectionMode
        ? IconButton(
            color: Colors.redAccent,
            onPressed: () async {
              await _deleteSelectedItems(objectKey);
            },
            icon: const Icon(
              Icons.delete_forever_outlined,
            ),
          )
        : Icon(
            _isItemSelected(objectKey)
                ? Icons.check_box_rounded
                : Icons.check_box_outline_blank,
            color: Colors.blue,
            size: UiConsts.largeIconSize,
          );
  }

  Future<dynamic> _toFullMediaViewPage(String objectKey) {
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (b) => FullMediaView(
                  fetchSourceData: FetchSourceData(
                      fetchSourceMethod: FetchSourceMethod.server,
                      cloudFileObjectKey: objectKey),
                  imageRendererConfigs: ImageDisplayConfigsModel(
                    filterQuality: FilterQuality.high,
                    displayImageMode: ExtendedImageMode.gesture,
                    allowCache: true,
                    // width: double.infinity,
                    // height: double.infinity
                  ),
                  objectType: MediaObjectType.image,
                )));
  }

  void _reportCurrentSelectedItems() {
    _logger.d(
        "Selected (${_isSelectedAllItems ? 'all,${_selectedItems.length}' : '${_selectedItems.length}'}) items: ${_selectedItems.join(", ")}");
  }

  void _selectOrDeselectItem(String objectKey) {
    setState(() {
      if (_selectedItems.contains(objectKey)) {
        _selectedItems.remove(objectKey);
      } else {
        _selectedItems.add(objectKey);
      }
    });
    _reportCurrentSelectedItems();
  }

  void _selectOrDeselectAllItems() {
    _logger.d("${_isSelectedAllItems ? 'Deselecting' : 'Selecting'} all items");
    setState(() {
      if (_isSelectedAllItems) {
        _selectedItems.clear();
      } else {
        _selectedItems.addAll(albumData!.linkedObjects.toSet());
      }
    });
    _reportCurrentSelectedItems();
  }

  void _onTapMediaItem(String objectKey) {
    if (!_isActivatedSelectionMode) {
      _toFullMediaViewPage(objectKey);
    } else {
      _selectOrDeselectItem(objectKey);
    }
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

  Future<void> _onLongPressMediaItem(String objectKey) async {
    // await _deleteCurrentItem(context, objectKey);
    if (_isActivatedSelectionMode) {
      await _toFullMediaViewPage(objectKey);
    }
  }

  void _onTouchedSelectItemsActionBtn() {
    _logger.d("select items action pressed");
    setState(() {
      _isActivatedSelectionMode = !_isActivatedSelectionMode;
    });
  }

  Future<void> _unlinkSelectedItems(List<String> objectKeys) async {
    _logger.d("unlinking selected items: $objectKeys");
  }

  Future<void> _deleteSelectedItems(String objectKey) async {
    // TODO: convert to delete selected multiple items action
    // ! delete from server, files must be in the same folder to delete
    final bool? confirmation = await DialogService.showConfirmationDialog(
        context: context,
        title: "Delete file?",
        message: "Are you sure to delete '${objectKey.split("/").last}'?",
        confirmText: "DELETE");
    if (confirmation == true) {
      if (_authWrapper.uid == "") _authWrapper.refreshUid();
      if (albumData is Map<String, dynamic>) {
        final ModificationData modificationData = albumData!.modificationData
            .copyWith(
                lastModifiedAt: Timestamp.now(),
                lastModifiedByUserId: _authWrapper.uid);
        final AlbumsModel updatedAlbumData = albumData!.copyWith(
          modificationData: modificationData,
          linkedObjects: albumData!.linkedObjects
              .where((obj) => obj != objectKey)
              .toList(),
        );
        _logger.d("updatedAlbumData: ${updatedAlbumData.toMap()}");
        setState(() {
          albumData = updatedAlbumData;
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
      AlbumsModel? albumData) async {
    _logger.d("delete single album action pressed");
    if (albumData == null)
      return; // TODO: add notification to user that album is not found
    final bool? result = await DialogService.showConfirmationDialog(
      context: context,
      title: 'Delete album',
      message: 'Are you sure you want to delete this album?',
    );
    if (result == true) {
      _logger.t('Deleting album');
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
      // Navigator.pop(context);
      return;
    }
  }

  void _toAddMoreMediaToAlbumPage() {}
}
