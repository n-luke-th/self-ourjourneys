/// lib/views/albums/albums_page.dart
///
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
import 'package:ourjourneys/helpers/utils.dart';
import 'package:ourjourneys/models/interface/actions_btn_model.dart';
import 'package:ourjourneys/models/modification_model.dart';
import 'package:ourjourneys/services/auth/acc/auth_wrapper.dart';
import 'package:ourjourneys/services/db/firestore_wrapper.dart';
import 'package:ourjourneys/shared/services/firestore_commons.dart';
import 'package:ourjourneys/shared/views/screen_sizes.dart';
import 'package:ourjourneys/shared/views/ui_consts.dart';

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
      _logger.e(e);
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
    _logger.i("fetching albums...");
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
            child: Padding(
                padding: UiConsts.PaddingAll_small,
                child: (_docs.isEmpty)
                    ? const Center(child: Text("No albums yet"))
                    : GridView.builder(
                        controller: _scrollController,
                        padding: UiConsts.PaddingAll_standard,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
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
                            return _albumTile(data, index);
                          }
                        },
                      ))));
  }

  void _onPressedSelectAlbumsActionBtn() =>
      _logger.d("select albums action pressed");

  Widget _albumTile(Map<String, dynamic> data, int index) {
    final name = data['albumName'] as String;
    final modData = ModificationData.fromMap(
        data['modificationData'] as Map<String, dynamic>);
    final (String createdString, String modifiedString) =
        ModificationData.getModificationDataString(
            modData: modData, uid: _authWrapper.uid);
    if (_authWrapper.uid == "") {
      _authWrapper.refreshUid();
    }
    return Container(
      margin: UiConsts.PaddingAll_small,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: UiConsts.BorderRadiusCircular_standard,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: UiConsts.BorderRadiusCircular_standard,
        ),
        visualDensity: VisualDensity.comfortable,
        enableFeedback: true,
        contentPadding: UiConsts.PaddingHorizontal_small,
        titleAlignment: ListTileTitleAlignment.center,
        isThreeLine: true,
        // leading: Text((index + 1).toString()),
        trailing: Text(
          "${data["linkedObjects"].length.toString()}\n${data["linkedObjects"].length <= 1 ? 'item' : 'items'}",
          maxLines: 2,
          softWrap: true,
          textAlign: TextAlign.center,
        ),
        title: Text(
          name,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(decoration: TextDecoration.underline),
        ),
        subtitle: Text(
          modifiedString,
          softWrap: true,
          maxLines: 5,
          overflow: TextOverflow.clip,
        ),
        style: ListTileStyle.drawer,
        onTap: () => context.goNamed("AlbumDetailsPage", extra: data),
        onLongPress: () => _onLongPressAlbumTile(data),
      ),
    );
  }

  void _onLongPressAlbumTile(Map<String, dynamic> data) {}
}
