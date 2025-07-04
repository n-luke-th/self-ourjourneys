/// lib/services/core/local_and_server_file_selection_provider.dart

import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:ourjourneys/models/storage/objects_data.dart' show ObjectsData;
import 'package:ourjourneys/models/storage/selected_file.dart'
    show SelectedFile;
import 'package:ourjourneys/shared/helpers/misc.dart' show FetchSourceMethod;

/// Selection state shared between local and server file selection
class LocalAndServerFileSelectionProvider with ChangeNotifier {
  final Set<SelectedFile> _selectedItems = {};
  LocalAndServerFileSelectionProvider();

  List<SelectedFile> get selectedLocalFilesAsList =>
      _selectedItems.where((i) => i.localFile != null).toList();
  List<SelectedFile> get selectedServerItemsAsList =>
      _selectedItems.where((i) => i.cloudObjectData != null).toList();

  List<ObjectsData> get selectedServerItemsAsObjsList =>
      selectedServerItemsAsList.map((i) => i.cloudObjectData!).toList();

  List<SelectedFile> get selectedAsList => _selectedItems.toList();

  void clearAll() {
    _selectedItems.clear();
    notifyListeners();
  }

  bool isSelected(SelectedFile item) => _selectedItems.contains(item);

  bool isSelectedServerFile(ObjectsData obj) =>
      selectedServerItemsAsObjsList.any((e) => (obj.objectKey == e.objectKey));

  bool isSelectedLocalFile(SelectedFile file) => selectedLocalFilesAsList
      .any((e) => e.localFile?.name == file.localFile?.name);

  void updateSelectedServerObjs(ObjectsData obj) {
    if (isSelectedServerFile(obj)) {
      _selectedItems
          .removeWhere((i) => i.cloudObjectData?.objectKey == obj.objectKey);
    } else {
      _selectedItems.add(SelectedFile(
          cloudObjectData: obj, fetchSourceMethod: FetchSourceMethod.server));
    }

    notifyListeners();
  }

  void removeGivenServerObjectFromSelection(ObjectsData object) {
    _selectedItems
        .removeWhere((o) => o.cloudObjectData?.objectKey == object.objectKey);
    notifyListeners();
  }

  void clearSelectedServerObjects() {
    _selectedItems.removeWhere((o) => o.cloudObjectData != null);
    notifyListeners();
  }

  void updateSelectedLocalFiles(
    List<SelectedFile> files,
  ) {
    _selectedItems.removeWhere((fs) => fs.localFile != null);
    _selectedItems.addAll(files.where((f) =>
        f.localFile != null &&
        selectedLocalFilesAsList
            .every((e) => e.localFile?.name != f.localFile?.name)));

    notifyListeners();
  }

  void updateSelectedLocalFile(
    SelectedFile file,
  ) {
    if (isSelectedLocalFile(file)) {
      _selectedItems
          .removeWhere((i) => i.localFile?.name == file.localFile?.name);
    } else {
      _selectedItems.add(file);
    }

    notifyListeners();
  }

  void clearSelectedLocalFiles() {
    _selectedItems.removeWhere((o) => o.localFile != null);

    notifyListeners();
  }
}
