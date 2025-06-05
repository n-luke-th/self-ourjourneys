/// lib/views/albums/albums_page.dart
///
// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart'
    show DocumentSnapshot, Query;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:logger/logger.dart';
import 'package:ourjourneys/components/main_view.dart';
import 'package:ourjourneys/components/more_actions_btn.dart'
    show MoreActionsBtn;
import 'package:ourjourneys/helpers/dependencies_injection.dart';
import 'package:ourjourneys/helpers/utils.dart' show Utils;
import 'package:ourjourneys/models/interface/actions_btn_model.dart';
import 'package:ourjourneys/models/modification_model.dart';
import 'package:ourjourneys/services/auth/acc/auth_wrapper.dart';
import 'package:ourjourneys/services/db/firestore_wrapper.dart';
import 'package:ourjourneys/services/dialog/dialog_service.dart';
import 'package:ourjourneys/shared/services/firestore_commons.dart'
    show FirestoreCollections;
import 'package:ourjourneys/shared/views/screen_sizes.dart';
import 'package:ourjourneys/shared/views/ui_consts.dart' show UiConsts;
import 'package:ourjourneys/views/cloud_file_uploader.dart';

/// a page to display a list of albums
class AlbumsPage extends StatefulWidget {
  const AlbumsPage({super.key});

  @override
  State<AlbumsPage> createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage> {
  final AuthWrapper _authWrapper = getIt<AuthWrapper>();
  final FirestoreWrapper _firestoreWrapper = getIt<FirestoreWrapper>();
  final Logger _logger = getIt<Logger>();
  final List<Map<String, dynamic>> _docs = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDoc;

  static const _pageSize = 20;

  @override
  initState() {
    super.initState();
    // getIdToken();
    _authWrapper.refreshUid();
    _authWrapper.refreshIdToken();
    _fetch();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void getIdToken() async {
    try {
      final idToken = _authWrapper.idToken;
      _logger.d("idToken: $idToken");
    } catch (e) {
      _logger.e(e.toString(), error: e, stackTrace: StackTrace.current);
    }
  }

  void _onScroll() async {
    if (_scrollController.position.pixels >
            _scrollController.position.maxScrollExtent - 300 &&
        !_isLoading &&
        _hasMore) {
      await _fetch();
    }
  }

  Future<void> _fetch({bool forceRefresh = false}) async {
    context.loaderOverlay.show();
    _logger.t("fetching albums...");
    setState(() => _isLoading = true);
    if (forceRefresh) {
      _docs.clear();
      _lastDoc = null;
      _hasMore = true;
    }
    Query query = _firestoreWrapper.queryCollection(FirestoreCollections.albums,
        orderBy: "albumName", descending: false, limit: _pageSize);

    if (_lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      _lastDoc = snapshot.docs.last;
      _docs.addAll(
        snapshot.docs.where((d) => d.id != "_").map((d) {
          final data = d.data() as Map<String, dynamic>;
          return {
            ...data,
            'id': d.id,
          };
        }),
      );
    }

    if (snapshot.docs.length < _pageSize) _hasMore = false;

    setState(() => _isLoading = false);

    context.loaderOverlay.hide();
  }

  @override
  Widget build(BuildContext context) {
    return mainView(context,
        appBarTitle: "ALBUMS",
        appBarLeading: IconButton.filled(
          tooltip: "Refresh data",
          onPressed: () async => _fetch(forceRefresh: true),
          icon: const Icon(
            Icons.sync_outlined,
          ),
        ),
        appbarActions: [
          Padding(
            padding: UiConsts.PaddingAll_standard,
            child: MoreActionsBtn(
              actions: [
                ActionsBtnModel(
                    actionName: "View all uploaded files",
                    icon: const Icon(
                      Icons.folder_outlined,
                    ),
                    onPressed: () => context.pushNamed("ViewAllFilesPage")),
                ActionsBtnModel(
                    actionName: "Upload files to server",
                    icon: const Icon(Icons.cloud_upload_outlined),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => CloudFileUploader(
                                  folderPath:
                                      Utils.getFolderPath(_authWrapper.uid),
                                )))),
                if (_docs.isNotEmpty)
                  ActionsBtnModel(
                      actionName: "Select Albums",
                      icon: const Icon(
                        Icons.check_circle_outline_outlined,
                      ),
                      onPressed: () => _onPressedSelectAlbumsActionBtn())
              ],
              displayIcon: const Icon(Icons.menu_outlined),
            ),
          ),
        ],
        showFloatingActionButton: true,
        floatingActionButtonTooltip: "Create new album",
        floatingActionButtonIcon: Icons.add_to_photos_outlined,
        onFloatingActionButtonPressed: () => context.pushNamed("NewAlbumPage"),
        body: Center(
            child: (_docs.isEmpty)
                ? Padding(
                    padding: UiConsts.PaddingAll_standard,
                    child: const Center(child: Text("No albums yet")),
                  )
                : GridView.builder(
                    controller: _scrollController,
                    padding: UiConsts.PaddingAll_small,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 8,
                      childAspectRatio: Utils.getScreenSize(
                                  MediaQuery.sizeOf(context).width) ==
                              ScreenSize.large
                          ? 2
                          : 0.9,
                    ),
                    itemCount: _docs.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _docs.length) {
                        // if (_isLoading) {
                        //   context.loaderOverlay.show();
                        // } else if (!_isLoading) {
                        //   context.loaderOverlay.hide();
                        // }
                        return const Center(child: SizedBox.shrink());
                      } else if (_docs.isEmpty) {
                        return const Center(child: Text("No albums yet"));
                      } else {
                        final data = _docs[index];
                        return _albumCard(data, index);
                      }
                    },
                  )));
  }

  void _onPressedSelectAlbumsActionBtn() =>
      _logger.d("select albums action pressed");

  Card _albumCard(Map<String, dynamic> albumData, int index) {
    final name = albumData['albumName'] as String;
    final modData = ModificationData.fromMap(
        albumData['modificationData'] as Map<String, dynamic>);
    final (String createdString, String modifiedString) =
        ModificationData.getModificationDataString(
            modData: modData, uid: _authWrapper.uid);
    if (_authWrapper.uid == "") {
      _authWrapper.refreshUid();
    }
    final ShapeBorder shape = BeveledRectangleBorder(
      borderRadius: UiConsts.BorderRadiusCircular_mediumLarge,
    );
    return Card(
      shape: shape,
      elevation: 5,
      shadowColor: Theme.of(context).highlightColor,
      surfaceTintColor: Theme.of(context).canvasColor,
      child: InkWell(
        borderRadius: UiConsts.BorderRadiusCircular_mediumLarge,
        customBorder: shape,
        child: Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 4, left: 8),
          child: Stack(
            children: [
              Align(
                alignment: AlignmentDirectional.topStart,
                child: Padding(
                  padding: UiConsts.PaddingAll_standard,
                  child: Text(
                      "${albumData["linkedObjects"].length.toString()}${albumData["linkedObjects"].length <= 1 ? ' item' : ' items'}",
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: Theme.of(context).disabledColor)),
                ),
              ),
              Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: IconButton.filled(
                    color: Colors.red,
                    onPressed: () async => await _deleteSelectedAlbums(),
                    icon: const Icon(Icons.delete_outline_rounded),
                  )),
              Align(
                alignment: AlignmentDirectional.bottomStart,
                child: Padding(
                  padding: UiConsts.PaddingAll_small,
                  child: Text(
                    modifiedString,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: Theme.of(context).hintColor),
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  maxLines: 2,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
        onTap: () => context.goNamed("AlbumDetailsPage", extra: albumData),
        onLongPress: () => _onLongPressAlbumTile(
            albumData: albumData,
            modifiedString: modifiedString,
            createdString: createdString),
      ),
    );
  }

  Future<void> _onLongPressAlbumTile(
      {required Map<String, dynamic> albumData,
      required String modifiedString,
      required String createdString}) async {
    await DialogService.showInfoDialog(
        context: context,
        title: "Album Info",
        message:
            "Name: ${albumData["albumName"]}\nContains: ${albumData["linkedObjects"].length.toString()} ${albumData["linkedObjects"].length <= 1 ? 'item' : 'items'}\n$createdString\n$modifiedString");
  }

  Future<void> _deleteSelectedAlbums() async {}
}
