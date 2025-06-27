/// lib/views/albums/album_details_page.dart
///

// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart'
    show FieldValue, Timestamp;
import 'package:extended_image/extended_image.dart' show ExtendedImageMode;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
import 'package:ourjourneys/services/core/album_details_provider.dart';
import 'package:ourjourneys/services/db/firestore_wrapper.dart';
import 'package:ourjourneys/services/dialog/dialog_service.dart';
import 'package:ourjourneys/shared/common/page_mode_enum.dart';
import 'package:ourjourneys/shared/helpers/misc.dart';
import 'package:ourjourneys/shared/services/firestore_commons.dart';
import 'package:ourjourneys/shared/views/ui_consts.dart' show UiConsts;
import 'package:ourjourneys/views/media/full_media_view.dart';
import 'package:provider/provider.dart';

/// a page to display the details of an album and a list of items associate with it
class AlbumDetailsPage extends StatefulWidget {
  final bool cloudImageAllowCache;

  const AlbumDetailsPage({super.key, this.cloudImageAllowCache = true});

  @override
  State<AlbumDetailsPage> createState() => _AlbumDetailsPageState();
}

class _AlbumDetailsPageState extends State<AlbumDetailsPage> {
  final AuthWrapper _authWrapper = getIt<AuthWrapper>();
  final CloudFileService _cloudFileService = getIt<CloudFileService>();
  final FirestoreWrapper _firestoreWrapper = getIt<FirestoreWrapper>();
  final Logger _logger = getIt<Logger>();
  final ScrollController _scrollController = ScrollController();

  late final AlbumsModel? albumData;

  late final ImageDisplayConfigsModel _displayConfigs;

  @override
  void initState() {
    super.initState();
    albumData =
        Provider.of<AlbumDetailsProvider>(context, listen: false).albumData;
    _displayConfigs = ImageDisplayConfigsModel(
        filterQuality: FilterQuality.low,
        allowCache: widget.cloudImageAllowCache,
        width: double.infinity,
        height: double.infinity);
  }

  @override
  void dispose() {
    albumData = null;
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isSelectingItems =>
      context.read<AlbumDetailsProvider>().isSelecting;

  bool get _isSelectedAllItems =>
      context.read<AlbumDetailsProvider>().isSelectedAll;

  /// change the current active mode to either of the following:
  /// - [PageMode.view]
  /// - [PageMode.edit]
  void _toggleMode() {
    context.read<AlbumDetailsProvider>().togglePageMode();
    _logger.d(
        "mode now is ${context.read<AlbumDetailsProvider>().currentPageMode.name}");
  }

  IconData _getFloatingActionBtnIcon() {
    return context.watch<AlbumDetailsProvider>().currentPageMode ==
            (PageMode.edit)
        ? Icons.edit
        : Icons.visibility_outlined;
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
              await _unlinkSelectedItems();
            },
            icon: const Icon(
              Icons.do_disturb_outlined,
              color: Colors.orange,
            )),
      IconButton.outlined(
          enableFeedback: true,
          tooltip: _isSelectingItems ? "Delete selected items" : "Delete album",
          onPressed: () async => await _onTouchedDeleteSingleAlbumActionBtn(),
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
    ];
  }

  @override
  Widget build(BuildContext context) {
    final BackButton backBtn = BackButton(
      onPressed: () => context.goNamed("AlbumsPage"),
    );

    if (albumData == null) {
      return mainView(context,
          appBarTitle: 'ALBUM DETAILS',
          appBarLeading: backBtn,
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
          appBarLeading: backBtn,
          appbarActions: [
            Padding(
              padding: UiConsts.PaddingAll_standard,
              child: IconButton.filled(
                  enableFeedback: true,
                  onPressed: () async => await DialogService.showInfoDialog(
                      context: context,
                      title: "ALBUM METADATA",
                      message:
                          "Contains: ${albumData!.linkedObjects.length} ${albumData!.linkedObjects.length <= 1 ? 'item' : 'items'}\n${modifiedString.isNotEmpty ? "$createdString\n$modifiedString" : createdString}"),
                  icon: const Icon(Icons.info_outline_rounded)),
            ),
          ],
          showFloatingActionButton: true,
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
          floatingActionButtonIcon: _getFloatingActionBtnIcon(),
          floatingActionButtonTooltip:
              "Toggle to ${context.read<AlbumDetailsProvider>().currentPageMode == PageMode.view ? 'Edit' : 'View'} mode",
          floatingActionButtonProps: FloatingActionButton(
            onPressed: () {},
            shape: RoundedSuperellipseBorder(
                borderRadius: UiConsts.BorderRadiusCircular_medium),
          ),
          onFloatingActionButtonPressed: () => _toggleMode(),
          bottomSheet: context
                  .read<AlbumDetailsProvider>()
                  .isActivatedSelectionMode
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
                      Provider.of<AlbumDetailsProvider>(context, listen: false)
                          .autoSelectAllOrDeselectAll();
                      _reportCurrentSelectedItems();
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
                    Utils.capitalizeFirstLetter(context
                        .read<AlbumDetailsProvider>()
                        .currentPageMode
                        .getIng),
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(color: Theme.of(context).cardColor),
                    softWrap: true,
                    maxLines: 2,
                    textAlign: TextAlign.start,
                  ),
                )),
                if (context.read<AlbumDetailsProvider>().currentPageMode ==
                    (PageMode.edit))
                  ..._buildActionsForEditMode(),
                if (context.read<AlbumDetailsProvider>().currentPageMode ==
                    (PageMode.view))
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
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: UiConsts.PaddingAll_standard,
                    addAutomaticKeepAlives: true, // <-- keep tiles alive
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 8,
                      childAspectRatio:
                          InterfaceUtils.isBigScreen(context) ? 2 : 0.9,
                    ),
                    itemCount: albumData!.linkedObjects.length,
                    itemBuilder: (_, index) {
                      final key = albumData!.linkedObjects[index];
                      return AlbumMediaItem(
                        key: ValueKey(key),
                        objectKey: key,
                        imageRendererConfigs: _displayConfigs,
                        selectionModeActive: context
                            .read<AlbumDetailsProvider>()
                            .isActivatedSelectionMode,
                        onTapCompleted: () => _reportCurrentSelectedItems(),
                      );
                    },
                  ),
                ),
              ])));
    }
  }

  void _reportCurrentSelectedItems() {
    final Set<String> selectedItems =
        context.read<AlbumDetailsProvider>().selectedItems;
    _logger.d(
        "Selected (${_isSelectedAllItems ? 'all,${selectedItems.length}' : '${selectedItems.length}'}) items: ${selectedItems.join(", ")}");
  }

  void _onTouchedSelectItemsActionBtn() {
    _logger.d("select items action pressed");
    setState(() {
      context.read<AlbumDetailsProvider>().toggleSelectionMode();
    });
  }

  Future<void> _unlinkSelectedItems() async {}

  void _toAddMoreMediaToAlbumPage() {}

  Future<void> _onTouchedDeleteSingleAlbumActionBtn() async {}
}

/// internal class to handle media item rendering on album page.
///
/// act as the wrapper of [MediaItemContainer] and [Container] widget.
///
/// as well as customizing media item rendering.
///
/// importantly, ensures identity is stable by passing `[key]: ValueKey(<unique_key_string_value>)`.

class AlbumMediaItem extends StatefulWidget {
  const AlbumMediaItem({
    super.key,
    required this.objectKey,
    required this.imageRendererConfigs,
    required this.selectionModeActive,
    this.onTapCompleted,
  });

  final String objectKey;
  final ImageDisplayConfigsModel imageRendererConfigs;
  final bool selectionModeActive;
  final VoidCallback? onTapCompleted;

  @override
  State<AlbumMediaItem> createState() => _AlbumMediaItemState();
}

class _AlbumMediaItemState extends State<AlbumMediaItem>
    with AutomaticKeepAliveClientMixin {
  late final Widget _mediaTile;

  @override
  void initState() {
    super.initState();
    // final album = context.read<AlbumDetailsProvider>();
    // Immutable part: MediaItemContainer (never rebuilt)
    _mediaTile = MediaItemContainer(
      key: ValueKey(widget.objectKey),
      mimeType: FileUtils.detectMimeTypeFromFilepath(widget.objectKey) ?? '',
      fetchSourceData:
          context.read<AlbumDetailsProvider>().getItem(widget.objectKey),
      imageRendererConfigs: widget.imageRendererConfigs,
      showActionWidget: false,
      onTap: () => _handleTap(context),
      onLongPress: () => _handleLongPress(context),
      onDoubleTap: () async => await _handleDoubleTap(widget.objectKey),
      showDescriptionBar: false,
      descriptionTxtMaxLines: 0,
      extraMapData: {'description': widget.objectKey.split('/').last},
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // The overlay reacts to selection changes only
    return Selector<AlbumDetailsProvider, bool>(
      selector: (_, p) => p.isSelected(widget.objectKey),
      builder: (_, isSelected, child) {
        final shouldShowOverlay = widget.selectionModeActive && isSelected;
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            child!, // <-- the immutable MediaItemContainer, never rebuilt
            if (shouldShowOverlay)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => _handleTap(context),
                  onLongPress: () => _handleLongPress(context),
                  onDoubleTap: () async =>
                      await _handleDoubleTap(widget.objectKey),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.amberAccent
                          .withAlpha(Color.getAlphaFromOpacity(0.5)),
                      borderRadius: UiConsts.BorderRadiusCircular_superLarge,
                    ),
                    child: const Icon(
                      Icons.check_box_rounded,
                      color: Colors.blue,
                      size: UiConsts.largeIconSize,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      child: Positioned.fill(child: _mediaTile),
    );
  }

  void _handleTap(BuildContext ctx) {
    final album = ctx.read<AlbumDetailsProvider>();
    if (!album.isActivatedSelectionMode) {
      _toFullMediaViewPage(widget.objectKey);
    } else {
      album.toggleSelect(widget.objectKey);
    }

    widget.onTapCompleted?.call();
  }

  void _handleLongPress(BuildContext ctx) {
    if (ctx.read<AlbumDetailsProvider>().isActivatedSelectionMode) {
      _toFullMediaViewPage(widget.objectKey);
    } else {}
  }

  Future<void> _handleDoubleTap(String objectKey) async {
    await DialogService.showCustomDialog(
      context,
      type: DialogType.information,
      title: "Information",
      message:
          "Media type: ${FileUtils.detectFileTypeFromFilepath(objectKey).stringValue}\nName: ${objectKey.split("/").last}\nObject key: $objectKey",
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
}

/// -- METHODS TEMP


  // Future<void> _deleteSelectedItems(String objectKey) async {
  //   // TODO: convert to delete selected multiple items action
  //   // ! delete from server, files must be in the same folder to delete
  //   final bool? confirmation = await DialogService.showConfirmationDialog(
  //       context: context,
  //       title: "Delete file?",
  //       message: "Are you sure to delete '${objectKey.split("/").last}'?",
  //       confirmText: "DELETE");
  //   if (confirmation == true) {
  //     if (_authWrapper.uid == "") _authWrapper.refreshUid();
  //     if (albumData is Map<String, dynamic>) {
  //       final ModificationData modificationData = albumData!.modificationData
  //           .copyWith(
  //               lastModifiedAt: Timestamp.now(),
  //               lastModifiedByUserId: _authWrapper.uid);
  //       final AlbumsModel updatedAlbumData = albumData!.copyWith(
  //         modificationData: modificationData,
  //         linkedObjects: albumData!.linkedObjects
  //             .where((obj) => obj != objectKey)
  //             .toList(),
  //       );
  //       _logger.d("updatedAlbumData: ${updatedAlbumData.toMap()}");

  //       await _firestoreWrapper.handleUpdateDocument(context,
  //           collectionName: FirestoreCollections.albums,
  //           data: updatedAlbumData.toMap(),
  //           docId: updatedAlbumData.id,
  //           suppressNotification: true);
  //     }

  //     final String? folder = FileUtils.getFolderPathFromObjectKey(objectKey);
  //     if (folder != null) {
  //       await _cloudFileService.deleteObjectsSameFolder(context,
  //           objectKeys: [objectKey], folder: folder);
  //     }
  //   }
  // }



  // Future<void> _unlinkSelectedItems() async {
  //   final List<String> objectKeys =
  //       Provider.of<AlbumDetailsProvider>(context, listen: false)
  //           .selectedItemsAsList;
  //   _logger.d("unlinking selected items: $objectKeys");
  // }

  // Future<void> _onTouchedDeleteSingleAlbumActionBtn() async {
  //   _logger.d("delete single album action pressed");
  //   final AlbumsModel? albumData =
  //       Provider.of<AlbumDetailsProvider>(context, listen: false).albumData;
  //   if (albumData == null)
  //     return; // TODO: add notification to user that album is not found
  //   final bool? result = await DialogService.showConfirmationDialog(
  //     context: context,
  //     title: 'Delete album',
  //     message: 'Are you sure you want to delete this album?',
  //   );
  //   if (result == true) {
  //     _logger.t('Deleting album');
  //     final List<String> objectsDataDocIds = await _firestoreWrapper
  //         .queryCollection(FirestoreCollections.objectsData, filters: [
  //           QueryFilter(
  //               "linkedAlbums", albumData.id, QueryCondition.arrayContains)
  //         ])
  //         .get()
  //         .then((result) => result.docs.map((doc) => doc.id).toList());
  //     _logger.d("objectsDataDocIds to be edited: $objectsDataDocIds");

  //     for (String docId in objectsDataDocIds) {
  //       _logger.d("Editing objectData docId: $docId");
  //       await _firestoreWrapper.handleUpdateDocument(context,
  //           collectionName: FirestoreCollections.objectsData,
  //           docId: docId,
  //           suppressNotification: true,
  //           data: {
  //             "linkedAlbums": FieldValue.arrayRemove([albumData.id])
  //           });
  //     }

  //     await _firestoreWrapper.handleDeleteDocument(
  //         context, FirestoreCollections.albums, albumData.id,
  //         suppressNotification: true);
  //     Navigator.pop(context);
  //   } else {
  //     // Navigator.pop(context);
  //     return;
  //   }
  // }

  // void _toAddMoreMediaToAlbumPage() {}