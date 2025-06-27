/// lib/services/core/album_details_provider.dart
///
import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:ourjourneys/helpers/utils.dart' show Utils;
import 'package:ourjourneys/models/db/albums_model.dart';
import 'package:ourjourneys/models/storage/fetch_source_data.dart';
import 'package:ourjourneys/shared/common/page_mode_enum.dart';
import 'package:ourjourneys/shared/helpers/misc.dart';

/// the data provider for album to improve performance
/// and to isolate the ui (widget tree) and (data, state),
/// also, reduces rebuilds
class AlbumDetailsProvider with ChangeNotifier {
  final AlbumsModel? albumData;
  final Set<String> _selected = {};

  late final Map<String, FetchSourceData> _mediaMap;
  late PageMode _mode;
  bool _isActivatedSelectionMode = false;

  AlbumDetailsProvider(this.albumData) {
    _mode = PageMode.view;
    _mediaMap = {
      if (albumData != null)
        for (final key in albumData!.linkedObjects)
          key: FetchSourceData(
              fetchSourceMethod: FetchSourceMethod.server,
              cloudFileObjectKey: Utils.getThumbnailKeyFromObjectKey(key))
    };
  }

  FetchSourceData getItem(String key) => _mediaMap[key]!;

  bool isSelected(String key) =>
      _selected.contains(key) && _isActivatedSelectionMode;

  bool get isSelectedAll =>
      _currentModeIs(PageMode.edit) && (_selected.length == _mediaMap.length);

  bool get isSelecting =>
      _currentModeIs(PageMode.edit) &&
      _selected.isNotEmpty &&
      _isActivatedSelectionMode;

  Set<String> get selectedItems => _selected;

  List<String> get selectedItemsAsList => _selected.toList();

  int get itemAmount =>
      (albumData != null) ? albumData!.linkedObjects.length : 0;

  PageMode get currentPageMode => _mode;

  bool get isActivatedSelectionMode => _isActivatedSelectionMode;

  bool get _isSelectingButNotAll =>
      _selected.isNotEmpty && _selected.length != _mediaMap.length;

  /// check if the current active mode is the one passed as parameter [toCompareMode]
  bool _currentModeIs(PageMode toCompareMode) {
    return toCompareMode == _mode;
  }

  void togglePageMode({PageMode? overrideModeTo}) {
    toggleSelectionMode(overrideSelectionModeTo: false);
    if (overrideModeTo == null) {
      _mode = _currentModeIs(PageMode.edit) ? PageMode.view : PageMode.edit;
    } else {
      _mode = overrideModeTo;
    }
    notifyListeners();
  }

  void toggleSelect(String key) {
    if (_selected.contains(key)) {
      _selected.remove(key);
    } else {
      _selected.add(key);
    }
    notifyListeners();
  }

  void selectAll() {
    _selected.addAll(_mediaMap.keys);
    notifyListeners();
  }

  void deselectAll() {
    _selected.clear();
    notifyListeners();
  }

  void autoSelectAllOrDeselectAll() {
    if (_selected.isEmpty || _isSelectingButNotAll) {
      selectAll();
    } else {
      deselectAll();
    }
  }

  void toggleSelectionMode({bool? overrideSelectionModeTo}) {
    if (overrideSelectionModeTo == null) {
      _isActivatedSelectionMode = !_isActivatedSelectionMode;
    } else {
      _isActivatedSelectionMode = overrideSelectionModeTo;
    }
    notifyListeners();
  }
}
