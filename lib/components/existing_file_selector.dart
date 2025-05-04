/// lib/components/existing_file_selector.dart

import 'package:flutter/material.dart';
import 'package:ourjourneys/components/main_view.dart';
import 'package:ourjourneys/helpers/dependencies_injection.dart';
import 'package:ourjourneys/models/storage/objects_data.dart';
import 'package:ourjourneys/services/db/firestore_wrapper.dart';
import 'package:ourjourneys/shared/services/firestore_commons.dart';
import 'package:ourjourneys/shared/views/ui_consts.dart';

class ExistingFileSelector extends StatefulWidget {
  final void Function(List<ObjectsData>) onSelectionChanged;

  const ExistingFileSelector({super.key, required this.onSelectionChanged});

  @override
  State<ExistingFileSelector> createState() => _ExistingFileSelectorState();
}

class _ExistingFileSelectorState extends State<ExistingFileSelector> {
  final FirestoreWrapper _firestoreWrapper = getIt<FirestoreWrapper>();
  List<ObjectsData> _allFiles = [];
  List<ObjectsData> _selected = [];
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  void _loadFiles() async {
    final data = await _firestoreWrapper
        .queryCollection(FirestoreCollections.objectsData,
            filters: [],
            limit: 100,
            orderBy: 'objectUploadRequestedAt',
            descending: false)
        .get();
    // .then((value) => value.docs.removeWhere(test)  value.docs.map((d)=> d.id));

    setState(() {
      _allFiles = data.docs
          .map((doc) => ObjectsData.fromMap(doc.data() as Map<String, dynamic>))
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
      appBarTitle: "Add from Existing files",
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
                  borderRadius: UiConsts.BorderRadiusCircular_standard,
                ),
              ),
            ),
            UiConsts.SizedBoxGapVertical_large,
            _allFiles.isEmpty
                ? const Text("No files found.")
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: filtered.map((obj) {
                      final isSelected =
                          _selected.any((o) => o.objectKey == obj.objectKey);
                      return ChoiceChip(
                        label: Text(obj.fileName),
                        selected: isSelected,
                        onSelected: (_) => _toggleSelection(obj),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}
