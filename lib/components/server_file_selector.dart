/// lib/components/server_file_selector.dart

import 'package:flutter/material.dart';
import 'package:ourjourneys/components/main_view.dart';
import 'package:ourjourneys/components/media_item_container.dart';
import 'package:ourjourneys/helpers/dependencies_injection.dart' show getIt;
import 'package:ourjourneys/models/interface/image_display_configs_model.dart';
import 'package:ourjourneys/models/storage/fetch_source_data.dart'
    show FetchSourceData;
import 'package:ourjourneys/models/storage/objects_data.dart' show ObjectsData;
import 'package:ourjourneys/services/db/firestore_wrapper.dart';
import 'package:ourjourneys/shared/helpers/misc.dart';
import 'package:ourjourneys/shared/services/firestore_commons.dart';
import 'package:ourjourneys/shared/views/ui_consts.dart' show UiConsts;

class ServerFileSelector extends StatefulWidget {
  final void Function(List<ObjectsData>) onSelectionChanged;
  final List<ObjectsData> selectedFiles;
  final bool cloudImageAllowCache;

  const ServerFileSelector(
      {super.key,
      this.cloudImageAllowCache = true,
      required this.onSelectionChanged,
      required this.selectedFiles});

  @override
  State<ServerFileSelector> createState() => _ServerFileSelectorState();
}

class _ServerFileSelectorState extends State<ServerFileSelector> {
  final FirestoreWrapper _firestoreWrapper = getIt<FirestoreWrapper>();
  List<ObjectsData> _allFiles = [];

  late List<ObjectsData> _selected;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadFiles();
    _selected = widget.selectedFiles;
  }

  void _loadFiles() async {
    final data = await _firestoreWrapper
        .queryCollection(FirestoreCollections.objectsData,
            filters: [],
            limit: 100,
            orderBy: 'objectUploadRequestedAt',
            descending: false)
        .get();

    setState(() {
      _allFiles = data.docs
          .map((doc) {
            if (doc.id == "_") {
              return null;
            } else {
              return ObjectsData.fromMap(doc.data() as Map<String, dynamic>);
            }
          })
          .whereType<ObjectsData>()
          .toList();
    });
  }

  void _toggleSelection(ObjectsData obj) {
    setState(() {
      if (_selected.any((o) => o.objectKey == obj.objectKey)) {
        _selected.removeWhere((o) => o.objectKey == obj.objectKey);
      } else {
        _selected.add(obj);
      }
    });
    widget.onSelectionChanged(_selected);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _allFiles
        .where(
            (f) => f.fileName.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();

    return mainView(
      context,
      appBarTitle: "Edit Selected Server files",
      body: Padding(
        padding: UiConsts.PaddingAll_large,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UiConsts.SizedBoxGapVertical_standard,
            TextField(
              onChanged: (value) => setState(() => _searchText = value),
              decoration: InputDecoration(
                hintText: "Search files...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: UiConsts.BorderRadiusCircular_mediumLarge,
                ),
              ),
            ),
            UiConsts.SizedBoxGapVertical_large,
            _allFiles.isEmpty
                ? const Text("No files found.")
                : Expanded(
                    child: SingleChildScrollView(
                      child: Center(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          alignment: WrapAlignment.center,
                          runAlignment: WrapAlignment.spaceAround,
                          spacing: 16,
                          runSpacing: 8,
                          children: filtered.map((obj) {
                            final isSelected = _selected
                                .any((o) => o.objectKey == obj.objectKey);
                            return SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.4,
                              child: ChoiceChip.elevated(
                                selectedColor: Theme.of(context)
                                    .colorScheme
                                    .tertiaryContainer,
                                showCheckmark: false,
                                selected: isSelected,
                                onSelected: (_) => _toggleSelection(obj),
                                tooltip: obj.fileName,
                                shape: RoundedRectangleBorder(
                                    borderRadius: UiConsts
                                        .BorderRadiusCircular_mediumLarge),
                                // avatar: const Icon(Icons.open_in_full_rounded),
                                // avatarBoxConstraints:
                                //     BoxConstraints.tightFor(width: 20),
                                labelPadding: UiConsts.PaddingVertical_small,
                                label: MediaItemContainer(
                                  showDescriptionBar: false,
                                  showWidgetBorder: false,
                                  showActionWidget: true,
                                  actionWidget: Icon(
                                    isSelected
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank,
                                    color:
                                        isSelected ? Colors.green : Colors.grey,
                                  ),
                                  mimeType: obj.contentType,
                                  widgetRatio: 1,
                                  fetchSourceData: FetchSourceData(
                                      fetchSourceMethod:
                                          FetchSourceMethod.server,
                                      cloudFileObjectKey:
                                          obj.objectThumbnailKey),
                                  imageRendererConfigs:
                                      ImageDisplayConfigsModel(
                                    filterQuality: FilterQuality.low,
                                    allowCache: widget.cloudImageAllowCache,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
