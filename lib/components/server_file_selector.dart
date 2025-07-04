/// lib/components/server_file_selector.dart
/// TODO: will move to `views/media` and no longer be a component
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ourjourneys/components/main_view.dart';
import 'package:ourjourneys/components/media_item_container.dart';
import 'package:ourjourneys/helpers/dependencies_injection.dart' show getIt;
import 'package:ourjourneys/models/interface/image_display_configs_model.dart';
import 'package:ourjourneys/models/storage/fetch_source_data.dart'
    show FetchSourceData;
import 'package:ourjourneys/models/storage/objects_data.dart' show ObjectsData;
import 'package:ourjourneys/services/core/local_and_server_file_selection_provider.dart';
import 'package:ourjourneys/services/db/firestore_wrapper.dart';
import 'package:ourjourneys/shared/helpers/misc.dart';
import 'package:ourjourneys/shared/services/firestore_commons.dart'
    show FirestoreCollections;
import 'package:ourjourneys/shared/views/ui_consts.dart' show UiConsts;
import 'package:provider/provider.dart'
    show ChangeNotifierProvider, ReadContext, Selector;

/// internal widget to display a single file as a tile
class _ServerFileTile extends StatefulWidget {
  const _ServerFileTile({
    required this.obj,
    required this.cfg,
    super.key,
  });

  final ObjectsData obj;
  final ImageDisplayConfigsModel cfg;

  @override
  State<_ServerFileTile> createState() => _ServerFileTileState();
}

class _ServerFileTileState extends State<_ServerFileTile>
    with AutomaticKeepAliveClientMixin {
  late final Widget _mediaTile; // heavy part - built once

  @override
  void initState() {
    super.initState();
    _mediaTile = MediaItemContainer(
      key: ValueKey(widget.obj.objectKey),
      mimeType: widget.obj.contentType,
      widgetRatio: 1,
      fetchSourceData: FetchSourceData(
        fetchSourceMethod: FetchSourceMethod.server,
        cloudFileObjectKey: widget.obj.objectThumbnailKey,
      ),
      imageRendererConfigs: widget.cfg,
      showActionWidget: false,
      showWidgetBorder: false,
      showDescriptionBar: false,
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Selector<LocalAndServerFileSelectionProvider, bool>(
      selector: (_, sel) => sel.isSelectedServerFile(widget.obj),
      builder: (_, isSel, child) => ChoiceChip.elevated(
        key: ValueKey(widget.obj.objectKey),
        selected: isSel,
        showCheckmark: false,
        selectedColor: Theme.of(context).colorScheme.tertiaryContainer,
        tooltip: widget.obj.fileName,
        shape: RoundedRectangleBorder(
          borderRadius: UiConsts.BorderRadiusCircular_mediumLarge,
        ),
        labelPadding: UiConsts.PaddingVertical_small,
        label: Stack(
          alignment: Alignment.topRight,
          children: [
            child!, // the cached MediaItemContainer
            Padding(
              padding: UiConsts.PaddingAll_small,
              child: Icon(
                isSel ? Icons.check_box : Icons.check_box_outline_blank,
                color: isSel ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
        onSelected: (_) => context
            .read<LocalAndServerFileSelectionProvider>()
            .updateSelectedServerObjs(widget.obj),
      ),
      child: _mediaTile,
    );
  }
}

/// a page to select files from the server to add to the collection or album
class ServerFileSelector extends StatefulWidget {
  final LocalAndServerFileSelectionProvider provider;
  const ServerFileSelector({
    super.key,
    this.cloudImageAllowCache = true,
    required this.provider,
  });

  final bool cloudImageAllowCache;

  @override
  State<ServerFileSelector> createState() => _ServerFileSelectorState();
}

class _ServerFileSelectorState extends State<ServerFileSelector> {
  final FirestoreWrapper _firestore = getIt<FirestoreWrapper>();
  final TextEditingController _search = TextEditingController();

  List<ObjectsData> _all = [];

  late final ImageDisplayConfigsModel _cfg = ImageDisplayConfigsModel(
    filterQuality: FilterQuality.low,
    allowCache: widget.cloudImageAllowCache,
    fit: BoxFit.contain,
    shouldShowRetryButton: false,
  );

  List<ObjectsData> get _filtered => _all
      .where(
          (f) => f.fileName.toLowerCase().contains(_search.text.toLowerCase()))
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    final snap = await _firestore
        .queryCollection(
          FirestoreCollections.objectsData,
          limit: 100,
          orderBy: 'objectUploadRequestedAt',
          descending: false,
        )
        .get();

    setState(() {
      _all = snap.docs
          .where((d) => d.id != '_')
          .map((d) => ObjectsData.fromMap(d.data() as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LocalAndServerFileSelectionProvider>.value(
      value: widget.provider,
      builder: (_, __) => mainView(
        context,
        appBarTitle: 'Edit Selected Server Files',
        body: Padding(
          padding: UiConsts.PaddingHorizontal_standard,
          child: Column(
            children: [
              UiConsts.SizedBoxGapVertical_standard,
              TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: 'Search files...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: UiConsts.BorderRadiusCircular_mediumLarge,
                    ),
                  ),
                  onChanged: (_) => setState(() {})),
              Expanded(
                child: _all.isEmpty
                    ? const Center(child: Text('No files found.'))
                    : GridView.builder(
                        padding: UiConsts.PaddingAll_standard,
                        addAutomaticKeepAlives: true,
                        gridDelegate: UiConsts.getSliverGridDelegate(context),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) => _ServerFileTile(
                          key: ValueKey(_filtered[i].objectKey),
                          obj: _filtered[i],
                          cfg: _cfg,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
