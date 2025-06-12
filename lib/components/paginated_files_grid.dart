/// lib/components/paginated_files_grid.dart

import 'package:cloud_firestore/cloud_firestore.dart'
    show DocumentSnapshot, Query;
import 'package:flutter/material.dart';
// import 'package:logger/logger.dart';
import 'package:ourjourneys/components/media_item_container.dart'
    show MediaItemContainer;
import 'package:ourjourneys/helpers/dependencies_injection.dart' show getIt;
import 'package:ourjourneys/helpers/utils.dart' show FileUtils;
import 'package:ourjourneys/models/interface/image_display_configs_model.dart';
import 'package:ourjourneys/models/storage/fetch_source_data.dart'
    show FetchSourceData;
import 'package:ourjourneys/models/storage/objects_data.dart';
import 'package:ourjourneys/services/cloud/cloud_file_service.dart';
import 'package:ourjourneys/services/db/firestore_wrapper.dart';
import 'package:ourjourneys/services/dialog/dialog_service.dart'
    show DialogService, DialogType;
import 'package:ourjourneys/shared/helpers/misc.dart' show FetchSourceMethod;
import 'package:ourjourneys/shared/services/firestore_commons.dart';
import 'package:ourjourneys/shared/views/ui_consts.dart' show UiConsts;
import 'package:ourjourneys/views/albums/full_media_view.dart';

/// A widget that displays a paginated grid of all files on the server.
class PaginatedFilesGrid extends StatefulWidget {
  final String? filterContentTypePrefix;
  final bool cloudImageAllowCache;

  const PaginatedFilesGrid(
      {super.key,
      this.filterContentTypePrefix,
      this.cloudImageAllowCache = true});

  @override
  State<PaginatedFilesGrid> createState() => _PaginatedFilesGridState();
}

class _PaginatedFilesGridState extends State<PaginatedFilesGrid> {
  final List<DocumentSnapshot> _docs = [];
  final ScrollController _scrollController = ScrollController();
  final FirestoreWrapper _firestoreWrapper = getIt<FirestoreWrapper>();
  final CloudFileService _cloudFileService = getIt<CloudFileService>();
  // final Logger _logger = getIt<Logger>();

  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDoc;

  static const _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _fetch();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >
            _scrollController.position.maxScrollExtent - 300 &&
        !_isLoading &&
        _hasMore) {
      _fetch();
    }
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    Query query;

    if (widget.filterContentTypePrefix != null) {
      query =
          _firestoreWrapper.queryCollection(FirestoreCollections.objectsData,
              filters: [
                QueryFilter("contentType", widget.filterContentTypePrefix,
                    QueryCondition.isGreaterThanOrEqualTo),
                QueryFilter(
                    "contentType",
                    // ignore: prefer_interpolation_to_compose_strings
                    widget.filterContentTypePrefix! + '\uf8ff',
                    QueryCondition.isLessThan)
              ],
              orderBy: "objectUploadRequestedAt",
              descending: true,
              limit: _pageSize);
    } else {
      query = _firestoreWrapper.queryCollection(
          FirestoreCollections.objectsData,
          orderBy: "objectUploadRequestedAt",
          descending: true,
          limit: _pageSize);
    }

    if (_lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      _lastDoc = snapshot.docs.last;
      _docs.addAll(snapshot.docs);
    }

    if (snapshot.docs.length < _pageSize) _hasMore = false;

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_docs.isEmpty && !_isLoading) {
      return const Center(child: Text('No content found.'));
    }

    return GridView.builder(
      controller: _scrollController,
      padding: UiConsts.PaddingAll_standard,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: _docs.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _docs.length) {
          return const Center(child: CircularProgressIndicator());
        }

        final objectsData =
            ObjectsData.fromMap(_docs[index].data() as Map<String, dynamic>);
        if (FileUtils.detectFileTypeFromMimeType(objectsData.contentType) ==
            MediaObjectType.image) {
          final objectKey = objectsData.objectKey;
          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
            child: MediaItemContainer(
              showDescriptionBar: false,
              fetchSourceData: FetchSourceData(
                  fetchSourceMethod: FetchSourceMethod.server,
                  cloudFileObjectKey: objectsData.objectThumbnailKey),
              imageRendererConfigs: ImageDisplayConfigsModel(
                  filterQuality: FilterQuality.low,
                  allowCache: widget.cloudImageAllowCache),
              mimeType: objectsData.contentType,
              mediaAndDescriptionBarFlexValue: (18, 1),
              descriptionTxtMaxLines: 1,
              extraMapData: {"description": objectKey.split("/").last},
              onLongPress: () async {
                await _handleOnLongPressItem(objectKey);
              },
              onDoubleTap: () async {
                await _onDoubleTapItem(objectKey);
              },
              onTap: () => _onTapItem(objectsData),
            ),
          );
        } else if (FileUtils.detectFileTypeFromMimeType(
                objectsData.contentType) ==
            MediaObjectType.video) {
          return const Icon(Icons.videocam, size: 48);
        } else {
          // return const Icon(Icons.insert_drive_file, size: 48);
          return ListTile(
            leading: Text((index + 1).toString()),
            title: Text(objectsData.toMap().toString()),
          );
        }
      },
    );
  }

  Future<dynamic> _onTapItem(ObjectsData objectData) {
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (b) => FullMediaView(
                  fetchSourceData: FetchSourceData(
                      fetchSourceMethod: FetchSourceMethod.server,
                      cloudFileObjectKey: objectData.objectKey),
                  imageRendererConfigs: ImageDisplayConfigsModel(
                      allowCache: widget.cloudImageAllowCache),
                  objectType: MediaObjectType.image,
                  extraMapData: {
                    "fileSizeInBytes": objectData.objectSizeInBytes
                  },
                )));
  }

  Future<void> _onDoubleTapItem(String objectKey) async {
    await DialogService.showCustomDialog(
      context,
      type: DialogType.information,
      title: "Information",
      message:
          "Media type: ${FileUtils.detectFileTypeFromFilepath(objectKey)}\nName: ${objectKey.split("/").last}\nObject key: $objectKey",
    );
  }

  Future<void> _handleOnLongPressItem(String objectKey) async {
    // TODO: add machanism to: 1. just remove file from albums and memories 2. delete file from server
    // ! delete from server, files must be in the same folder to delete
    final bool? confirmation = await DialogService.showConfirmationDialog(
        context: context,
        title: "Delete file?",
        message: "Are you sure to delete '${objectKey.split("/").last}'?",
        confirmText: "DELETE");
    if (confirmation == true) {
      // TODO: also remove the reference from the albums and memories first before deleting the file

      await _cloudFileService
          // ignore: use_build_context_synchronously
          .deleteObjectsByKeys(context, objectKeys: [objectKey]);
    }
  }
}
